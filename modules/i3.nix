{ pkgs, ... }: {
  services.xserver = {
    displayManager.defaultSession = "none+i3";

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        cpanel
        dmenu
        dunst
        feh
        i3lock-color
        i3status
        main-menu
        picom
        scrot
      ];
    };
  };
}
