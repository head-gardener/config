{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.easyeffects;

in
{

  options.services.easyeffects = {
    enable = mkEnableOption "easyeffects";

    package = mkPackageOption pkgs "easyeffects" { };

    args = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = [
        "--load-preset music"
        "--bypass 2"
      ];
      description = lib.mdDoc ''
        Arguments passed to easyeffects binary.
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.easyeffects = {
      description = "EasyEffects";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];

      serviceConfig = {
        ExecStart = "${getExe cfg.package} ${concatStringsSep " " cfg.args}";
        RestartSec = 3;
        Restart = "always";
      };
    };

    environment.systemPackages = [ cfg.package ];
  };

}
