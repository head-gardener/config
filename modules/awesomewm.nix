{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    awesome
    i3lock-color
    i3status
  ];

  environment.pathsToLink = [ "/share/awesome" ];

  services.xserver = {
    enable = true;

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        awesome-wm-widgets
      ];
    };
  };
}
