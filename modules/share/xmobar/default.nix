{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.xmobar;

  configFile = pkgs.writeText "xmobarrc" cfg.config;

in
{

  options.services.xmobar = {
    enable = mkEnableOption "xmobar";

    package = mkPackageOptionMD pkgs.haskellPackages "xmobar" { };

    config = mkOption {
      type = types.lines;
      default = "Config {}";
      example = ''
        Config { bgColor  = "#3c3c3c"
               , fgColor  = "#f8f8f2"
               , commands = [ ]
               , template = "%whoami% }{ %date%"
               }
      '';
      description = lib.mdDoc ''
        Configuration for xmobar.
      '';
    };

    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "-b \"#3c3c3c\""
        "-t \"%whoami% }{ %date%\""
      ];
      description = lib.mdDoc ''
        Arguments passed to xmobar binary.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.xmobar = {
      description = "xmobar status bar";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} ${concatStringsSep " " cfg.args} ${configFile}";
        RestartSec = 3;
        Restart = "always";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };

}
