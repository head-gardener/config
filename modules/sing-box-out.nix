{ inputs, config, pkgs, ... }:
{
  age.secrets.vmess-uuid = {
    file = "${inputs.self}/secrets/vmess-uuid.age";
  };

  systemd.services.sing-box.restartTriggers = [ "${config.age.secrets.vmess-uuid.file}" ];

  services.sing-box = {
    enable = true;
    package = inputs.unstable.legacyPackages.${pkgs.system}.sing-box;
    settings = {
      inbounds = [
        {
          listen = "::";
          listen_port = 19555;
          type = "vmess";
          tag = "vmess-in";
          users = [{
            name = "default";
            uuid._secret = config.age.secrets.vmess-uuid.path;
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
        rules = [
          {
            geoip = [ "private" ];
            outbound = "direct";
          }
        ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 19555 ];
}
