{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.impermanence
    inputs.self.nixosModules.zram
  ];

  services.backup-local.subvols = [ "root" "var" ];
  # services.backup-s3.subvols = [ "root" ];

  services.prometheus.exporters.smartctl = {
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
    enable = true;
    port = 4002;
  };

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  environment.persistence."/persistent" = {
    directories = [
      {
        directory = "/etc/vault";
        user = "root";
        group = "root";
        mode = "u=rwx,g=,o=";
      }
    ];
  };

  networking.networkmanager.enable = false;

  environment.systemPackages = with pkgs; [
    ntfs3g
    fish
  ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;

  fileSystems."/mnt/minio" = {
    device = "/dev/disk/by-uuid/795ba0eb-b8a5-4253-a8a4-bb703053ccb8";
    fsType = "btrfs";
    options = [
      "subvol=minio"
      "compress=zstd"
    ];
  };

  system = {
    autoUpgrade = {
      enable = false;
      allowReboot = true;
      dates = "hourly";
      flake = "github:head-gardener/config";
      flags = [ ];
    };
  };

  programs = {
    atop = {
      enable = true;
      atopService.enable = true;
      atopRotateTimer.enable = true;
      netatop.enable = true;
      settings = {
        interval = 5;
        flags = "1fA";
      };
    };
  };
}
