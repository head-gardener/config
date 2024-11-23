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
    personal.va.templates.s3-backup = {
      contents = ''
        {{ with secret "services/minio/backup" }}{{ .Data.data.user }}:{{ .Data.data.pass }}{{ end }}
      '';
      for = "mnt-s3_backup.mount";
    };

    personal.s3-mounts.backup = {
      after = [ "vault-agent-machine.service" ];
      mountPoint = "/mnt/s3_backup";
      passwdFile = config.personal.va.templates.s3-backup.destination;
      umask = "077";
    };

    environment.systemPackages = [ pkgs.gzip pkgs.gnupg ];

    personal.va.templates.gpg-backup-key = {
      path = "services/gpg/${config.networking.hostName}";
      field = "key";
    };

    # TODO: create hostName dir in a systemd oneshot or something

    # fuck it
    systemd.services.btrbk-s3.serviceConfig.User = lib.mkForce "root";
    systemd.services.btrbk-s3.serviceConfig.Group = lib.mkForce "root";

    systemd.services.btrbk-s3.after = [ "mnt_s3-backup.mount" ];

    systemd.services.btrbk-s3.preStart = ''
      echo importing backup encryption keys...
      ${lib.getExe pkgs.gnupg} --import ${config.personal.va.templates.gpg-backup-key.destination}
    '';

    systemd.timers.btrbk-s3.timerConfig.RandomizedDelaySec = "1h";

    services.btrbk.extraPackages = [ pkgs.gnupg pkgs.gzip ];
    services.btrbk.instances.s3 = {
      settings = {
        raw_target_compress = "gzip";
        raw_target_encrypt = "gpg";

        gpg_keyring = config.personal.va.templates.gpg-backup-key.destination;
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
