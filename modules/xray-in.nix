{ public }:
{ alloy, lib, ... }:
{
  services.xray = {
    enable = true;
    settings = {
      inbounds = [{
        port = 1080;
        protocol = "socks";
        settings = {
          auth = "noauth";
        };
        sniffing = {
          destOverride = [ "http" "tls" ];
          enabled = true;
        };
      }];

      outbounds = [{
        protocol = "vmess";
        settings = {
          vnext = [{
            address = alloy.xray-out.host;
            port = 19555;
            users = [{
              alterId = 64;
              id = "b74f08d3-f406-4d79-afa1-0917d19c2b92";
            }];
          }];
        };
      }];
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkIf public [ 1080 ];
}
