{ pkgs, inputs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    i3lock-color
    i3status
  ];

  services.xmobar = {
    enable = true;
    config = builtins.readFile "${inputs.self}/dots/xmobar/xmobarrc";
  };

  services.xserver.windowManager.myxmonad = { };
}
