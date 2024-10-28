{ config, lib, ... }:

let
  inherit (lib) types mkOption genAttrs const;
  cfg = config.services.backup-local;
in
{
  options.services.backup-local = {
    subvols = mkOption {
      type = types.listOf types.str;
      default = [ "root" "var" ];
      example = [
        "root"
        "home"
      ];
      description = lib.mdDoc ''
        Subvolumes to create backups of.
      '';
    };
  };

  config = {
    systemd.timers.btrbk-local.timerConfig.RandomizedDelaySec = "1h";

    services.btrbk.instances.local = {
      settings = {
        snapshot_create = "ondemand";
        snapshot_dir = "snapshots";
        snapshot_preserve = "no";
        snapshot_preserve_min = "latest";
        target = "/mnt/btr_backup/default";
        target_preserve = "14d";
        target_preserve_min = "2d";
        volume = {
          "/mnt/btr_pool" = {
            subvolume = genAttrs cfg.subvols (const {});
          };
        };
      };
    };
  };
}
