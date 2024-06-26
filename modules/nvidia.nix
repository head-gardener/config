{ lib, pkgs, ... }:
{
  nixpkgs.config.nvidia.acceptLicense = true;
  nixpkgs.allowUnfreeByName = [
    "nvidia-x11"
    "nvidia-settings"
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [

    ];
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
