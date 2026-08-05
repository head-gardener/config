{
  config,
  inputs,
  lib,
  modulesPath,
  ...
}:
let
  cfg = config.personal.installer;

  kexec = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.self.nixosModules.installer-common
      inputs.self.nixosModules.installer-kexec
    ]
    ++ cfg.extraImports.all
    ++ cfg.extraImports.kexec;
  };

  softreboot = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs; };
    modules = [
      inputs.self.nixosModules.installer-common
      inputs.self.nixosModules.installer-softreboot
    ]
    ++ cfg.extraImports.all
    ++ cfg.extraImports.softreboot;
  };
in
{
  imports = [
    "${modulesPath}/image/repart.nix"

    inputs.self.nixosModules.installer-config-common
    inputs.self.nixosModules.installer-config-efi
    inputs.self.nixosModules.installer-config-bios
  ];

  options.personal.installer = {
    extraImports = {
      all = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
      };
      kexec = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
      };
      softreboot = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [ ];
      };
    };

    artifacts = {
      kexec = lib.mkOption {
        readOnly = true;
        type = lib.types.raw;
      };
      softreboot = lib.mkOption {
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
  };

  config = {
    personal.installer.artifacts.kexec = kexec;
    personal.installer.artifacts.softreboot = softreboot;

    system.build.installer.kexec = cfg.artifacts.kexec.config.system.build.kexecTree;
    system.build.installer.softreboot = cfg.artifacts.softreboot.config.system.build.tarball;
    system.build.installer.squashfs = cfg.artifacts.softreboot.config.system.build.squashfsStore;
  };
}
