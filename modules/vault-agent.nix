{ alloy, lib, pkgs, config, ... }:
let
  cfg = config.personal.va;

  applyTemplate = n:
    t@{ owner ? "root", group ? "root", ... }:
    {
      inherit owner group;
      destination = "${cfg.secretsMountPoint}/${n}";
    } // t;

  mkTemplate = n:
    t@{ perms ? "0400", destination, ... }:
    {
      create_dest_dirs = false;
      error_on_missing_key = true;
      inherit perms destination;
      contents = if t ? "contents" then
        t.contents
      else
        ''{{ with secret "${t.path}" }}{{ .Data.data.${t.field} }}{{ end }}'';
    } // (if t ? "for" then {
      exec = [{
        command = pkgs.writeShellScript "${n}-on-update" ''
          ${config.systemd.package}/bin/systemctl is-active '${t.for}' && \
            ${config.systemd.package}/bin/systemctl restart '${t.for}'
        '';
      }];
    } else
      { });

  # vault agent preserves owner of template destinations
  initTemplate = n: t: ''
    touch "${cfg.secretsMountPoint}/${n}"
    chown "${t.owner}:${t.group}" "${cfg.secretsMountPoint}/${n}"
  '';
in {
  options = {
    personal.va = {
      templates = lib.mkOption {
        default = { };
        type = with lib.types; lazyAttrsOf (lazyAttrsOf raw);
        apply = lib.mapAttrs applyTemplate;
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
      '' + (builtins.concatStringsSep "\n"
        (lib.mapAttrsToList initTemplate cfg.templates));
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
          sinks = [{
            sink = [{
              type = "file";
              config = [{
                path = "${cfg.secretsMountPoint}/token";
                owner = config.ids.uids.root;
                group = config.ids.gids.root;
                mode = 400;
              }];
            }];
          }];
        }];
        template = lib.attrValues (lib.mapAttrs mkTemplate cfg.templates);
        template_config = [{
          exit_on_retry_failure = true;
          max_connections_per_host = 10;
          static_secret_render_interval = "1m";
        }];
        vault = [{
          address = "http://${alloy.vault.config.services.vault.address}";
        }];
      };
    };
  };
}
