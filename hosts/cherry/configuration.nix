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
