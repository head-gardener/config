{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/disk/by-id/ata-WDC_WD3200AAKS-00L9A0_WD-WCAV20767916";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = false;

  environment.systemPackages = with pkgs; [
    ntfs3g
  ];

  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;

  services.btrbk = {
    instances.default = {
      settings = {
        snapshot_preserve = "14d";
        snapshot_preserve_min = "2d";
        volume = {
          "/mnt/btr_pool" = {
            snapshot_dir = "snapshots";
            snapshot_preserve_min = "all";
            snapshot_create = "no";
            subvolume = {
              var = {
                snapshot_create = "always";
              };
              root = {
                snapshot_create = "always";
              };
            };
            target = "/mnt/btr_backup/default";
          };
        };
      };
    };
  };

  system = {
    autoUpgrade = {
      enable = true;
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
