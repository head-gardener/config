{ alloy, lib, ... }:
{
  networking.firewall.allowedTCPPorts =
    lib.mkIf (alloy.nginx.host != alloy.grafana.host) [ 2342 ];

  services.grafana = {
    enable = true;
    settings.server = {
      domain = "backyard-hg.xyz";
      http_port = 2342;
      http_addr =
        if
          (alloy.nginx.host != alloy.grafana.host)
        then alloy.grafana.host
        else "127.0.0.1";
    };
  };
}
