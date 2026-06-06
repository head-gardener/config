{
  lib,
  inputs,
  config,
  pkgs,
  ...
}:
{
  options = {
    personal.sing-box.vaultless = lib.mkOption {
      description = "Run sing-box exit node without requiring vault agent";
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
    personal.va.templates.vless-uuid = lib.mkIf (!config.personal.sing-box.vaultless) {
      path = "services/sing-box/vless-uuid";
      field = "uuid";
      for = "sing-box.service";
    };

    personal.va.templates.reality-privkey = lib.mkIf (!config.personal.sing-box.vaultless) {
      path = "services/sing-box/reality-privkey";
      field = "privkey";
      for = "sing-box.service";
    };

    personal.va.templates.reality-short-id = lib.mkIf (!config.personal.sing-box.vaultless) {
      path = "services/sing-box/reality-short-id";
      field = "shortid";
      for = "sing-box.service";
    };

    services.sing-box = {
      enable = true;
      package = inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sing-box;
      settings = {
        log.level = "warn";
        inbounds = [
          {
            listen = "::";
            listen_port = 443;
            type = "vless";
            tag = "vless-in";
            users = [
              {
                name = "default";
                uuid._secret = lib.mkMerge [
                  (lib.mkIf
                    (!config.personal.sing-box.vaultless)
                    config.personal.va.templates.vless-uuid.destination)
                  (lib.mkIf
                    config.personal.sing-box.vaultless
                    "/run/secret/vless-uuid")
                ];
                flow = "xtls-rprx-vision";
              }
            ];
            tls = {
              enabled = true;
              server_name = "yandex.ru";
              reality = {
                enabled = true;
                handshake = {
                  server = "yandex.ru";
                  server_port = 443;
                };
                private_key._secret = lib.mkMerge [
                  (lib.mkIf
                    (!config.personal.sing-box.vaultless)
                    config.personal.va.templates.reality-privkey.destination)
                  (lib.mkIf
                    config.personal.sing-box.vaultless
                    "/run/secret/reality-privkey")
                ];
                short_id._secret = lib.mkMerge [
                  (lib.mkIf
                    (!config.personal.sing-box.vaultless)
                    config.personal.va.templates.reality-short-id.destination)
                  (lib.mkIf
                    config.personal.sing-box.vaultless
                    "/run/secret/reality-short-id")
                ];
              };
            };
          }
        ];
        outbounds = [
          {
            tag = "direct";
            type = "direct";
          }
        ];
        route = {
          final = "direct";
          auto_detect_interface = true;
          rules = [
            {
              ip_is_private = true;
              outbound = "direct";
            }
          ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 ];
  };
}
