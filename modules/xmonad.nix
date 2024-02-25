{ pkgs, inputs, lib, ... }:
let
  myxmonad = inputs.xmonad.packages.${pkgs.system}.default;
in
{
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
      session = [{
        manage = "window";
        name = "xmonad";
        start = ''
          systemd-cat -t xmonad -- ${lib.getExe myxmonad} &
          waitPID=$!
        '';
      }];
    };
  };
}
