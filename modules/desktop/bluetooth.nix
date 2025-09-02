{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    blueberry
    pavucontrol
  ];
}
