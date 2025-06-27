{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    i3lock-color
    i3status
  ];

  services.xserver = {
    enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = [ ];
    };
  };
}
