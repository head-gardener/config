{ lib, pkgs, ... }:
{
  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.allowUnfreeByName = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  hardware.graphics = {
    enable = true;
  };

  services = {
    xserver.videoDrivers = [ "nvidia" ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
  };
}
