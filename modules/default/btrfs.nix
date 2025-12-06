{
  config,
  lib,
  pkgs,
  ...
}:
let
  detect = lib.pipe config.fileSystems [
    lib.attrsToList
    (builtins.filter (x: x.value.fsType == "btrfs"))
    (map (x: x.value.device))
    lib.unique
  ];
  enable = builtins.length detect != 0;
  cfg = config.btrfs.autoConfigure;
  mkBalancer =
    dev:
    let
      devEscaped =
        lib.replaceStrings
          [
            "\\"
            "/"
            " "
            "@"
            ":"
            "["
            "]"
          ]
          [
            "_"
            "_"
            "_"
            "_"
            "_"
            "_"
            "_"
          ]
          dev;
    in
    {
      services."balance${devEscaped}" = {
        description = "Balance BTRFS on ${dev}";
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.gnugrep
          pkgs.util-linux
        ];

        script = ''
          set -eo pipefail;

          tgt="$(findmnt --noheadings --types btrfs --options subvolid=5 \
            --output TARGET --notruncate "${dev}" | head -1)"
          thres="$(btrfs filesystem show --raw "$tgt" \
            | grep devid \
            | awk '{ printf "%d", 10 + ($6 / $4)*20 }')"
          echo "Balancing ${dev} at $tgt with threshold $thres"
          btrfs balance start "$tgt" "-dusage=$thres" --enque
        '';

        unitConfig = {
          ConditionPathExists = [
            dev
          ];
        };

        serviceConfig = {
          # this is basically unrestrictable, since balance requires CAP_SYS_ADMIN
          # and rw fs mount, once you have that you can really do anything.
          PrivateTmp = true;
          PrivateMounts = true;
          NoNewPrivileges = true;
          CapabilityBoundingSet = "CAP_SYS_ADMIN";
          AmbientCapabilites = "CAP_SYS_ADMIN";
          ProtectSystem = "no";
          ProtectHome = "read-only";
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          MemoryDenyWriteExecute = true;
          PrivateDevices = false;

          Type = "oneshot";
        };
      };

      timers."balance${devEscaped}" = {
        description = "Balance BTRFS on ${dev}";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "Sat";
          RandomizedDelaySec = "4h";
          Persistent = true;
          Unit = "balance${devEscaped}.service";
        };
      };
    };
in
{
  options.btrfs.autoConfigure.disable = lib.mkOption {
    default = false;
    description =
      "Whether to skip setting btrfs-related configuration" + " regardless of the file system used";
    type = lib.types.bool;
  };

  config = lib.mkIf (enable && !cfg.disable) {
    services = {
      btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = detect;
      };
    };

    # might not work idk
    virtualisation.docker.storageDriver = "btrfs";

    systemd = lib.mkMerge (lib.map mkBalancer detect);
  };
}
