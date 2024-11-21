{ inputs, pkgs, config, lib, ... }:

let
  inherit (lib) types mkOption genAttrs const;
  cfg = config.services.backup-s3;
in
{
  imports = [
    inputs.self.nixosModules.s3-mounts
  ];

  options.services.backup-s3 = {
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
    age.secrets.s3-backup = { file = "${inputs.self}/secrets/s3-backup.age"; };

    personal.s3-mounts.backup = {
      mountPoint = "/mnt/s3_backup";
      passwdFile = config.age.secrets.s3-backup.path;
    };

    environment.systemPackages = [ pkgs.gzip pkgs.gnupg ];

    age.secrets.gpg-backup-key = {
      file = "${inputs.self}/secrets/gpg/${config.networking.hostName}.age";
    };

    system.activationScripts.import-gpg.deps = [ "agenix" ];
    system.activationScripts.import-gpg.text = ''
      echo importing backup encryption keys...
      ${lib.getExe pkgs.gnupg} --import ${config.age.secrets.gpg-backup-key.path}
    '';

    # TODO: create hostName dir in a systemd oneshot or something

    # fuck it
    systemd.services.btrbk-s3.serviceConfig.User = lib.mkForce "root";
    systemd.services.btrbk-s3.serviceConfig.Group = lib.mkForce "root";

    systemd.timers.btrbk-s3.timerConfig.RandomizedDelaySec = "1h";

    services.btrbk.extraPackages = [ pkgs.gnupg pkgs.gzip ];
    services.btrbk.instances.s3 = {
      settings = {
        raw_target_compress = "gzip";
        raw_target_encrypt = "gpg";

        gpg_keyring = config.age.secrets.gpg-backup-key.path;
        gpg_recipient = config.networking.hostName;

        snapshot_create = "ondemand";
        snapshot_dir = "snapshots";
        snapshot_preserve = "no";
        snapshot_preserve_min = "latest";
        incremental = "no";

        target =
          "raw ${config.personal.s3-mounts.backup.mountPoint}/${config.networking.hostName}";
        target_preserve = "14d";
        target_preserve_min = "2d";

        volume = {
          "/mnt/btr_pool" = {
            subvolume = genAttrs cfg.subvols (const { });
          };
        };
      };
    };
  };
}
