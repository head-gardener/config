{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.conky;

  configFile = pkgs.writeText "conkyrc" cfg.config;

in
{

  options.services.conky = {
    enable = mkEnableOption "conky";

    package = mkPackageOption pkgs "conky" { };

    config = mkOption {
      type = types.lines;
      default = "";
      example = ''
        conky.config={
          update_interval=10,
          out_to_console=true,
          out_to_stderr=false,
        };

        conky.text = [[
        I am on ''${wireless_ap wlan0} and there
        are ''${user_number} users on my system
        ]]
      '';
      description = lib.mdDoc ''
        Configuration file for conky.
      '';
    };

    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "-u 15"
        "-x 100"
        "-y 200"
      ];
      description = lib.mdDoc ''
        Arguments passed to conky binary.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.conky = {
      description = "Conky system monitor";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart =
          "${getExe' cfg.package "conky"} ${concatStringsSep " " cfg.args}"
          + (optionalString (config != "") " -c ${configFile}");
        RestartSec = 3;
        Restart = "always";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };

}
