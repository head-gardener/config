{ pkgs, ... }: {
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.xserver = {
    libinput.enable = true;

    enable = true;

    layout = "us,ru";
    xkbOptions = "eurosign:e,caps:super,grp:ralt_rshift_toggle";

    desktopManager = {
      xterm.enable = false;
    };
  };
}
