{
  pkgs,
  config,
  inputs,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.personal.kexecInstaller;

  installerCommon =
    { pkgs, modulesPath, ... }:
    {
      imports = [
        "${modulesPath}/profiles/image-based-appliance.nix"
      ];

      users.users.root.initialPassword = "root";
      services.getty.autologinUser = "root";

      i18n.glibcLocales = null;

      systemd.settings.Manager.ShowStatus = "yes";

      systemd.services.installer = {
        description = "Auto-install disk image";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [
          pkgs.curl
          pkgs.zstd
        ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          StandardOutput = "journal+console";
          StandardError = "journal+console";
        };
        script = ''
          set -euxo pipefail

          image_url="''${image_url:-}"
          target_disk="''${target_disk:-}"

          if [ -z "$image_url" ]; then
            echo "No image url provided, skipping auto-install"
            exit 1
          fi

          if \
            ( [ -z "$target_disk" ] && echo -n "No target disk given. " ) || \
            ( [ "$target_disk" == "auto" ] && echo -n "Target disk set to 'auto'. " ); then
            target_disk="$(
              lsblk --filter "type=='disk'" --noheadings -o name -x size -p \
              | head -1)"
            echo "Detected target disk to be $target_disk"
          fi

          echo "Waiting for network connectivity..."
          for i in $(seq 1 30); do
            if curl -fsSL --head --connect-timeout 2 -I "$image_url"; then
              echo "Network is ready."
              break
            fi
            echo "  waiting... ($i/30)"
            sleep 2
          done

          decompress=zstd
          case "$image_url" in
            *.zst) decompress="zstd -d" ;;
            *) decompress=cat ;;
          esac

          touch /run/installer-started

          echo "Downloading and writing disk image from $image_url to $target_disk..."
          curl -fsSL --retry 15 --retry-delay 5 --retry-all-errors "$image_url" \
            | $decompress \
            | dd of="$target_disk" bs=4M conv=fsync status=progress

          echo "Installation complete! Rebooting..."
          sync
          sleep 3
          reboot -f
        '';
      };

      systemd.services.watchdog = lib.mkIf (cfg.watchdogSeconds > 0) {
        description = "Reset the machine if the installer never starts";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "infinity";
          StandardOutput = "journal+console";
          StandardError = "journal+console";
        };
        script = ''
          sleep ${toString cfg.watchdogSeconds}
          if [ -e /run/installer-started ]; then
            echo "Installer is writing to disk, standing down."
            exit 0
          fi
          echo "Installer never started, resetting."
          echo b > /proc/sysrq-trigger
        '';
      };
    };

  kexecInstaller = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      installerCommon
      (
        { modulesPath, lib, ... }:
        {
          imports = [
            "${modulesPath}/installer/netboot/netboot.nix"
            "${modulesPath}/profiles/perlless.nix"
          ];

          boot.kernelParams = [
            "installer.image_url="
            "installer.target_disk="
          ];

          services.userborn.static = true;

          # brought in by netboot which doesn't gate on nix.enabled
          systemd.services.register-nix-paths.enable = false;

          systemd.services.installer.script = lib.mkBefore ''
            for o in $(</proc/cmdline); do
              case "$o" in
                installer.image_url=*) [ -n "$image_url" ] || image_url="''${o#*=}" ;;
                installer.target_disk=*) [ -n "$target_disk" ] || target_disk="''${o#*=}" ;;
              esac
            done
          '';
        }
      )
    ]
    ++ cfg.extraImports;
  };

  # An installer entered with `systemctl soft-reboot`, which swaps userspace
  # for /run/nextroot without ever restarting the kernel. Needs no free memory
  # to speak of, unlike kexec, which has to pin a whole second kernel image.
  nextrootInstaller = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      installerCommon
      (
        {
          config,
          pkgs,
          lib,
          modulesPath,
          ...
        }:
        let
          osRelease = pkgs.runCommand "nextroot-os-release" { } ''
            cp -L ${config.system.build.toplevel}/etc/os-release $out
          '';
        in
        {
          boot.isContainer = true;

          services.userborn = {
            enable = true;
            static = true;
          };

          console.enable = true;
          systemd.services.console-getty.enable = false;

          networking.resolvconf.enable = false;
          networking.useHostResolvConf = false;
          networking.firewall.enable = false;

          systemd.services.installer.serviceConfig.EnvironmentFile = lib.mkBefore "-/etc/installer.env";
          systemd.services.installer.script = lib.mkBefore ''
            image_url="''${IMAGE_URL:-}"
            target_disk="''${TARGET_DISK:-}"
          '';

          system.build.tarball = pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
            fileName = "nextroot";
            extraArgs = "--owner=0";

            compressCommand = "zstd -T0 -19";
            compressionExtension = ".zst";
            extraInputs = [ pkgs.zstd ];

            contents = [
              {
                source = config.system.build.toplevel + "/init";
                target = "/sbin/init";
              }
              {
                source = osRelease;
                target = "/etc/os-release";
              }
            ];
          };

          system.build.squashfsStore = pkgs.callPackage "${modulesPath}/../lib/make-squashfs.nix" {
            fileName = "nextroot-store";
            storeContents = [ config.system.build.toplevel ];
            comp = "zstd -Xcompression-level 19";
            hydraBuildProduct = true;
          };
        }
      )
    ]
    ++ cfg.nextrootExtraImports;
  };

  inherit (pkgs.stdenv.hostPlatform) efiArch;

  isBios = cfg.firmware == "bios";

  # grub-bios-setup aborts when its `--directory` has no resolvable backing
  # block device, someone already patched that out
  grubBiosSetupPatchSrc = pkgs.fetchFromGitHub {
    owner = "songqing-sq";
    repo = "sonic_rules";
    rev = "4860a499a62f3f64c57b6dce95134a933fed5917";
    sparseCheckout = [ "grub/grub-bios-setup-no-mountinfo.patch" ];
    hash = "sha256-2CeQY1VgClaZlVNu3AoQUueLbopt3KwSTjtni1UcQqw=";
  };

  grubPkg = pkgs.grub2.overrideAttrs (old: {
    patches = (old.patches or [ ]) ++ [
      "${grubBiosSetupPatchSrc}/grub/grub-bios-setup-no-mountinfo.patch"
    ];
  });

  grubKernel = "${config.boot.kernelPackages.kernel}/${config.system.boot.loader.kernelFile}";
  grubInitrd = "${config.system.build.initialRamdisk}/${config.system.boot.loader.initrdFile}";

  grubCfg = pkgs.writeText "grub.cfg" ''
    set timeout=1
    set default=0
    insmod part_gpt
    insmod btrfs
    set root=(hd0,gpt2)
    menuentry "NixOS" {
      linux ${grubKernel} init=${config.system.build.toplevel}/init ${lib.concatStringsSep " " config.boot.kernelParams}
      initrd ${grubInitrd}
    }
  '';
in
{
  imports = [
    "${modulesPath}/image/repart.nix"
  ];

  options.personal.kexecInstaller = {
    extraImports = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
    nextrootExtraImports = lib.mkOption {
      type = lib.types.listOf lib.types.deferredModule;
      default = [ ];
    };
    watchdogSeconds = lib.mkOption {
      type = lib.types.int;
      default = 300;
      description = ''
        Reset the machine unless the installer has begun writing to disk within
        this many seconds, recovering from a transition that lost the network.
        0 disables the watchdog.

        Only the window before the write is covered - a reset during the write
        leaves an unbootable disk.
      '';
    };
    firmware = lib.mkOption {
      type = lib.types.enum [
        "bios"
        "uefi"
      ];
      default = "bios";
      description = ''
        Firmware the target boots with.

        "bios" (default) produces a legacy BIOS-bootable image: GPT with a
        `bios_grub` partition and GRUB (i386-pc) embedded via grub-bios-setup.
        Required for hosts whose firmware is legacy BIOS/SeaBIOS only, such as
        DigitalOcean droplets.

        "uefi" produces the UKI + systemd-boot image booted purely via the ESP.
      '';
    };
    # TODO: implement
    flavor = lib.mkOption {
      type = lib.types.strMatching "0\.5g|1g|xl";
      default = "xl";
    };
    installer = lib.mkOption {
      readOnly = true;
      type = lib.types.raw;
    };
    nextroot = lib.mkOption {
      readOnly = true;
      type = lib.types.raw;
    };
    grubPackage = lib.mkOption {
      readOnly = true;
      type = lib.types.package;
      description = ''
        The GRUB package used to embed the BIOS bootloader into the disk image.

        This is `pkgs.grub2` patched so that `grub-bios-setup` can operate on a
        raw image file inside the Nix build sandbox (where the staging directory
        has no resolvable backing block device).
      '';
    };
    # TODO: implement/rename
    unwrap = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkMerge [
    {
      personal.kexecInstaller.installer = kexecInstaller;
      personal.kexecInstaller.nextroot = nextrootInstaller;
      personal.kexecInstaller.grubPackage = grubPkg;
      system.build.kexecInstaller = cfg.installer.config.system.build.kexecTree;
      system.build.nextrootTarball = cfg.nextroot.config.system.build.tarball;
      system.build.nextrootSquashfs = cfg.nextroot.config.system.build.squashfsStore;

      boot.loader.efi.canTouchEfiVariables = false;

      boot.initrd.systemd.enable = true;
      boot.initrd.systemd.repart.enable = true;
      boot.growPartition = lib.mkForce false;

      image.repart = {
        name = "root";

        mkfsOptions.btrfs = [
          "--shrink"
          "-m"
          "single"
        ];

        compression = {
          enable = true;
          algorithm = "zstd";
          level = 19;
        };

        partitions."20-root" = {
          storePaths = [ config.system.build.toplevel ];
          contents."/nix-path-registration".source = "${
            pkgs.closureInfo { rootPaths = [ config.system.build.toplevel ]; }
          }/registration";
          repartConfig = {
            Type = "root";
            Format = "btrfs";
            Label = "nixos";
            Minimize = "guess";
            GrowFileSystem = true;
          };
        };
      };

      systemd.repart.partitions."20-root" = {
        Type = "root";
      };

      # TODO: make this a unit
      boot.postBootCommands = ''
        if [ -f /nix-path-registration ]; then
          ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration
          ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system \
            --set /run/current-system
          rm -f /nix-path-registration
        fi
      '';

      fileSystems."/" = {
        device = "/dev/disk/by-partlabel/nixos";
        fsType = "btrfs";
        options = [ "x-systemd.growfs" ];
      };
    }
    (lib.mkIf (!isBios) {
      boot.loader = {
        grub.enable = lib.mkForce false;
        systemd-boot.enable = lib.mkForce true;
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-partlabel/ESP";
        fsType = "vfat";
        options = [ "umask=0077" ];
      };

      image.repart.partitions."10-esp" = {
        contents = {
          "/EFI/BOOT/BOOT${lib.toUpper efiArch}.EFI".source =
            "${pkgs.systemd}/lib/systemd/boot/efi/systemd-boot${efiArch}.efi";
          "/EFI/Linux/${config.system.boot.loader.ukiFile}".source =
            "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
        };
        repartConfig = {
          Type = "esp";
          Format = "vfat";
          Label = "ESP";
          SizeMinBytes = "512M";
          SizeMaxBytes = "512M";
        };
      };

      system.build.repartImage = config.system.build.image;
    })
    (lib.mkIf isBios {
      boot.loader = {
        systemd-boot.enable = lib.mkForce false;
        grub = {
          enable = lib.mkForce true;
          efiSupport = false;
          devices = lib.mkForce [ "/dev/vda" ];
        };
      };

      image.repart.partitions."10-bios".repartConfig = {
        Type = "21686148-6449-6e6f-744e-656564454649";
        Label = "bios";
        SizeMinBytes = "1M";
        SizeMaxBytes = "1M";
      };

      image.repart.partitions."20-root".contents = {
        "/boot/grub/grub.cfg".source = grubCfg;
        "/boot/grub/i386-pc".source = "${grubPkg}/lib/grub/i386-pc";
      };

      system.build.repartImage = config.system.build.image.overrideAttrs (old: {
        preInstall = (old.preInstall or "") + ''
          echo "Embedding GRUB (i386-pc) into ${config.image.baseName}.raw"
          mkdir -p grub-boot
          cp ${grubPkg}/lib/grub/i386-pc/boot.img grub-boot/boot.img
          ${grubPkg}/bin/grub-mkimage \
            --format=i386-pc \
            --directory=${grubPkg}/lib/grub/i386-pc \
            --prefix='(hd0,gpt2)/boot/grub' \
            --output=grub-boot/core.img \
            biosdisk part_gpt btrfs normal linux configfile search search_fs_uuid search_label echo test gzio all_video loadenv
          echo '(hd0) ${config.image.baseName}.raw' > device.map
          ${grubPkg}/bin/grub-bios-setup \
            --verbose \
            --skip-fs-probe \
            --device-map=device.map \
            --directory=grub-boot \
            ${config.image.baseName}.raw
        '';
      });
    })
  ];
}
