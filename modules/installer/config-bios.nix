{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.personal.installer;

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
  config = lib.mkIf (cfg.firmware == "bios") {
    personal.installer.artifacts.grubPackage = grubPkg;

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
  };
}
