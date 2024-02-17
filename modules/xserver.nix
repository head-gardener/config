{ pkgs, inputs, ... }: {
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.unclutter-xfixes.enable = true;

  services.conky = {
    enable = true;
    config = builtins.readFile "${inputs.self}/dots/conky/conkyrc";
  };

  environment.systemPackages = with pkgs; [
    networkmanager_dmenu
  ];

  services.keyd = {
    enable = true;
    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          main = {
            capslock = "overload(control, esc)";
            space = "overload(meta, space)";
          };
        };
      };
    };
  };

  services.xserver = {
    libinput.enable = true;

    enable = true;

    layout = "us,ru";
    xkbOptions = "eurosign:e,grp:ralt_rshift_toggle";

    desktopManager = {
      xterm.enable = false;
    };
  };
}
