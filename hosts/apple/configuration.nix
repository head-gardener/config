{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    device = "/dev/sda";
  };

  networking.networkmanager.enable = false;

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      dates = "hourly";
      flake = "github:head-gardener/config";
      flags = [ ];
    };
  };

  system.stateVersion = "23.11";

  # services.logind.extraConfig = ''
  #   HandleLidSwitch=ignore
  #   HandleLidSwitchExternalPower=ignore
  # '';
}

