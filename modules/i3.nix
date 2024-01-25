{ pkgs, ... }:
{
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.xserver = {
    libinput.enable = true;

    enable = true;

    layout = "us,ru";
    xkbOptions = "eurosign:e,caps:super,grp:alt_shift_toggle";

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+i3";
    };

    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        cpanel
        dmenu
        dunst
        feh
        i3lock-color
        i3status
        kitty
        main-menu
        picom
        scrot
      ];
    };
  };
}
