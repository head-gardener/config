{ alloy, lib, inputs, pkgs, config, ... }:
{
  age.secrets.vmess-uuid = {
    file = "${inputs.self}/secrets/vmess-uuid.age";
  };

  # disable autostart
  systemd.services.sing-box.wantedBy = lib.mkForce [];
  systemd.services.sing-box.restartTriggers = [ "${config.age.secrets.vmess-uuid.file}" ];

  services.sing-box = {
    enable = true;
    package = inputs.unstable.legacyPackages.${pkgs.system}.sing-box;
    settings = {
      inbounds = [
        {
          type = "tun";
          inet4_address = [ "172.18.0.1/30" ];
          auto_route = true;
          strict_route = true;
        }
      ];
      outbounds = [
        { tag = "direct"; type = "direct"; }
        { tag = "block"; type = "block"; }
        {
          tag = "vmess-out";
          type = "vmess";
          server = alloy.sing-box-out.address;
          server_port = 19555;
          alter_id = 0;
          uuid._secret = config.age.secrets.vmess-uuid.path;
        }
      ];
      route = {
        final = "vmess-out";
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
}
