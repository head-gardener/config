{ alloy, lib, config, ... }:
let
  cfg = config.personal.va;
  mkTemplate = n: t:
    {
      create_dest_dirs = false;
      perms = "0400";
    } // t // {
      destination = "${cfg.secretsMountPoint}/${n}";
    };
in {
  options = {
    personal.va = {
      templates = lib.mkOption {
        default = { };
        type = with lib.types; lazyAttrsOf (lazyAttrsOf raw);
        apply = lib.mapAttrs mkTemplate;
      };
      secretsMountPoint = lib.mkOption {
        default = "/run/vault";
        type = lib.types.str;
      };
    };
  };

  config = {
    nixpkgs.allowUnfreeByName = [ "vault" ];
    systemd.services.vault.after = [ config.personal.wg.service ];

    system.activationScripts.vault-agent-mount = {
      deps = [ "specialfs" ];
      text = ''
        mkdir -p "${cfg.secretsMountPoint}"
        chmod 0751 "${cfg.secretsMountPoint}"
        grep -q "${cfg.secretsMountPoint} ramfs" /proc/mounts ||
          mount -t ramfs none "${cfg.secretsMountPoint}" -o nodev,nosuid,mode=0751
      '';
    };

    services.vault-agent.instances.machine = {
      enable = true;

      settings = {
        auto_auth = [{
          method = [{
            config = [{
              remove_secret_id_file_after_reading = false;
              role_id_file_path = "/etc/vault/role_id";
              secret_id_file_path = "/etc/vault/secret_id";
            }];
            type = "approle";
          }];
        }];
        template = lib.attrValues cfg.templates;
        template_config = [{
          exit_on_retry_failure = true;
          max_connections_per_host = 10;
          static_secret_render_interval = "5m";
        }];
        vault = [{
          address = "http://${alloy.vault.config.services.vault.address}";
        }];
      };
    };
  };
}
