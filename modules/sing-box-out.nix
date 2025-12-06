{ inputs, config, pkgs, ... }:
{
  personal.va.templates.vmess-uuid = {
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
          users = [{
            name = "default";
            uuid._secret = config.personal.va.templates.vmess-uuid.destination;
            alterID = 0;
          }];
          tls = {
            enabled = false;
          };
        }
      ];
      outbounds = [
        { tag = "direct"; type = "direct"; }
      ];
      route = {
        final = "direct";
        auto_detect_interface = true;
        rules = [ ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 19555 ];
}
