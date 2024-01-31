{ pkgs, inputs, ... }: {
  services.urxvtd.enable = true;

  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
      defaultSession = "none+xmonad";
      lightdm = {
        enable = true;
      };
    };

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      config = builtins.readFile "${inputs.self}/dots/xmonad/xmonad.hs";
      extraPackages = hpkgs: with hpkgs; [
      ];
    };
  };
}
