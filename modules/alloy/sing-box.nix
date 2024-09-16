{ lib, inputs, pkgs, ... }:
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
          tag = "socks-out";
          type = "socks";
          server = "192.168.1.102";
          server_port = 1080;
          version = "5";
        }
      ];
      route = {
        final = "socks-out";
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
