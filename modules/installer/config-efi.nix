{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.personal.installer;

  inherit (pkgs.stdenv.hostPlatform) efiArch;
in
{
  config = lib.mkIf (cfg.firmware == "uefi") {
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
  };
}
