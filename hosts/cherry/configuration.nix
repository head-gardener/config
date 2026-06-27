{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.impermanence
    inputs.self.nixosModules.zram
  ];

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
    fish
  ];

  networking.firewall.allowedTCPPorts = [ 5000 3000 ];
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
