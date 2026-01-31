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
    personal.va.templates.vmess-uuid = lib.mkIf (!config.personal.sing-box.vaultless) {
      path = "services/sing-box/vmess-uuid";
      field = "uuid";
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
            listen_port = 19555;
            type = "vmess";
            tag = "vmess-in";
            users = [
              {
                name = "default";
                uuid._secret = lib.mkMerge [
                  (lib.mkIf
                    (!config.personal.sing-box.vaultless)
                    config.personal.va.templates.vmess-uuid.destination)
                  (lib.mkIf
                    config.personal.sing-box.vaultless
                    "/run/secret/vmess-uuid")
                ];
                alterID = 0;
              }
            ];
            tls = {
              enabled = false;
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
          rules = [ ];
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 19555 ];
  };
}
