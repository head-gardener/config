{ pkgs, inputs, lib, system, ... }:
let
  myxmonad = inputs.xmonad.packages.${system}.default;
in
{
  services.urxvtd.enable = true;

  environment.systemPackages = with pkgs; [
    cpanel
    dmenu
    dunst
    feh
    i3lock-color
    i3status
    kitty
    main-menu
    myxmonad
    picom
    scrot
    xcolor
    xorg.xmessage
  ];

  services.xmobar = {
    enable = true;
    config = builtins.readFile "${inputs.self}/dots/xmobar/xmobarrc";
  };

  services.xserver = {
    displayManager = {
      defaultSession = "none+xmonad";
    };

    windowManager.session = [{
      name = "xmonad";
      start = ''
        systemd-cat -t xmonad -- ${lib.getExe myxmonad} &
        waitPID=$!
      '';
    }];
  };
}
