{ config, ... }:
{
  services.gnome.sushi.enable = true;

  programs.kdeconnect.enable = true;

  programs.dconf.enable = true;

  systemd.user.services.kdeconnectd = {
    description = "KDE Connect daemon";
    serviceConfig = {
      ExecStart = "${config.programs.kdeconnect.package}/bin/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 3;
    };
  };
}
