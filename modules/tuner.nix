{ alloy, pkgs, config, lib, net, ... }: {
  options = {
    services.tuner = {
      subject = lib.mkOption {
        type = lib.types.str;
        default = "nixos.autoupgrade";
      };
      server = lib.mkOption {
        type = lib.types.str;
        default = net.hosts.${alloy.nats.hostname}.ipv4;
      };
      after = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ config.personal.wg.service ];
      };
      configPath = lib.mkOption {
        type = lib.types.str;
        default = "github:head-gardener/config";
      };
    };
  };

  config = let
    cfg = config.services.tuner;
    rebuildArgs = "switch --flake";
    refExpr = "[a-z0-9]{40}";
  in {
    users.users.tuner = {
      group = "tuner";
      description = "Tuner service user";
      createHome = false;
      isSystemUser = true;
    };

    users.groups.tuner = { };

    security.sudo.extraRules = [{
      users = [ "tuner" ];
      commands = [{
        command = "${lib.getExe pkgs.nixos-rebuild} ^${rebuildArgs} "
          + "${lib.replaceStrings [ ":" ] [ "\\:" ] cfg.configPath}/${refExpr}$";
        options = [ "NOPASSWD" ];
      }];
    }];

    systemd.services.tuner = {
      description = "Autoupgrade listener";
      wantedBy = [ "multi-user.target" ];
      after = cfg.after;

      path = [ pkgs.natscli pkgs.nixos-rebuild pkgs.gnused ];

      script = ''
        ref="$(nats sub "${cfg.subject}" --server "${cfg.server}" --count 1 \
          | sed -nr 's/REF=(${refExpr})/\1/p')"
        [ -n "$ref" ] || { echo "Empty ref!"; exit 1; }
        # wait for all CI jobs to finish
        sleep 1
        # nixos-rebuild really wants sudo in PATH
        PATH="/run/wrappers/bin:$PATH"
        sudo ${
          lib.getExe pkgs.nixos-rebuild
        } ${rebuildArgs} "${cfg.configPath}/$ref"
      '';

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        User = "tuner";
        Group = "tuner";
      };
    };
  };
}
