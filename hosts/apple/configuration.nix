{ inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
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

  system.stateVersion = "24.05";

  # services.logind.extraConfig = ''
  #   HandleLidSwitch=ignore
  #   HandleLidSwitchExternalPower=ignore
  # '';
}
