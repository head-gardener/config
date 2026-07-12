{ pkgs, ... }:
{
  hardware.bluetooth.enable = true;

  hardware.bluetooth.settings = {
    General = {
      ControllerMode = "dual";
      MultiProfile = "multiple";
      FastConnectable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    blueberry
    pavucontrol
  ];
}
