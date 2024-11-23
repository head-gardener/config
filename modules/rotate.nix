{ alloy, inputs, pkgs, lib, config, ... }:
let
  mkSystemd = path: conf:
    let unitName = "rotate-${builtins.replaceStrings [ "/" ] [ "_" ] path}";
    in {
      services.${unitName} = {
        description = "Rotate ${path}";
        path = [
          pkgs.bash
          pkgs.curl
          pkgs.getent
          pkgs.jq
          pkgs.vault
        ] ++ conf.extraPackages;

        environment = { VAULT_ADDR = cfg.vaultAddr; };

        script = ''
          role_id="$(cat "$CREDENTIALS_DIRECTORY/role_id")"
          secret_id="$(cat "$CREDENTIALS_DIRECTORY/secret_id")"
          export VAULT_TOKEN="$(vault write -format=json auth/approle/login \
            "role_id=$role_id" "secret_id=$secret_id" \
            | jq -r .auth.client_token)"
          [ "$VAULT_TOKEN" ] || { echo empty response!; exit 1; }

          ${conf.script} ${path}
        '';

        unitConfig = {
          ConditionPathExists = [
            conf.rolePath
            conf.secretPath
          ];
        };

        serviceConfig = {
          LoadCredential = [
            "role_id:${conf.rolePath}"
            "secret_id:${conf.secretPath}"
          ];
          DynamicUser = true;
          Type = "oneshot";
          User = "rotate";
        };
      };

      timers.${unitName} = {
        description = "Rotate ${path}";
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = conf.onCalendar;
          RandomizedDelaySec = "4h";
          Persistent = true;
          Unit = "${unitName}.service";
        };
      };
    };

  cfg = config.personal.rotate;
in {
  options = {
    personal.rotate = {
      enable = lib.mkEnableOption "rotate";
      vaultAddr = lib.mkOption {
        type = lib.types.str;
        default = "http://${alloy.vault.config.services.vault.address}";
      };
      paths = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            onCalendar = lib.mkOption { type = lib.types.str; };
            script = lib.mkOption {
              type = lib.types.package;
              default = pkgs.writeScript "rotate.sh"
                (builtins.readFile "${inputs.self}/terraform/rotate.sh");
            };
            rolePath = lib.mkOption {
              type = lib.types.str;
              default = "/etc/vault/rotate/role_id";
            };
            secretPath = lib.mkOption {
              type = lib.types.str;
              default = "/etc/vault/rotate/secret_id";
            };
            extraPackages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [ ];
            };
          };
        });
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd = lib.mkMerge (lib.mapAttrsToList mkSystemd cfg.paths);
  };
}
