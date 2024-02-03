{ pkgs, inputs, ... }: {
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

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = builtins.readFile "${inputs.self}/dots/xmonad/xmonad.hs";
      extraPackages = hpkgs: with hpkgs; [
        libnotify
      ];
    };
  };
}
