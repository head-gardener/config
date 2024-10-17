{ alloy, lib, inputs, pkgs, ... }:
{
  # disable autostart
  systemd.services.sing-box.wantedBy = lib.mkForce [];

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
          server = alloy.xray-out.address;
          server_port = 19555;
          alter_id = 0;
          uuid = "b74f08d3-f406-4d79-afa1-0917d19c2b92";
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
