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

  escapeDev =
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
      ];

  mkBalancer =
    dev:
    let
      devEscaped = escapeDev dev;
    in
    {
      services."balance${devEscaped}" = {
        description = "Balance BTRFS on ${dev}";
        path = [
          pkgs.btrfs-progs
          pkgs.gawk
          pkgs.util-linux
        ];

        script = ''
          set -eo pipefail;

          tgt="$(findmnt --noheadings --types btrfs --options subvolid=5 \
            --output TARGET --notruncate "${dev}" | head -1)"
          thres="$(btrfs filesystem show --raw "$tgt" \
            | awk '/devid/ { printf "%d", 10 + ($6 / $4)*20 }')"
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
  options.btrfs.autoConfigure = {
    disable = lib.mkOption {
      default = false;
      description =
        "Whether to skip setting btrfs-related configuration" + " regardless of the file system used";
      type = lib.types.bool;
    };

    compressStore = lib.mkOption {
      default = false;
      description = "Whether to compress /nix/store periodically";
      type = lib.types.bool;
    };
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

    systemd = lib.mkMerge ((lib.map mkBalancer detect) ++ [
    (lib.mkIf cfg.compressStore {
      services.compress-store = {
        description = "Compress /nix/store";
        path = [
          pkgs.bash
          pkgs.btrfs-progs
          pkgs.compsize
          pkgs.gawk
          pkgs.util-linux
        ];

        script = ''
          set -o pipefail;

          if [ \
            "$(df -P /nix/store | awk 'NR==2 { print int($4 / $2 * 100) }')" -le 10 \
            -a "$( \
              compsize -b /nix/store \
              | awk '/none/ { none = $4 }; /zstd/ { zstd = $4 }; END { print (none*2 > zstd) }' \
            )" == "1" \
          ]; then
            echo "Compressing /nix/store..."
            unshare -m bash -e -c '
              mount -o remount,rw /nix/store
              btrfs filesystem defragment -czstd -r /nix/store
            '
          fi
        '';

        unitConfig = {
          ConditionPathExists = [
            "/nix/store"
          ];
        };

        serviceConfig = {
          Type = "oneshot";
        };
      };

      timers.compress-store = {
        description = "Compress /nix/store";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = "daily";
          RandomizedDelaySec = "4h";
          Persistent = true;
          Unit = "compress-store.service";
        };
      };
    })
    ]);
  };
}
