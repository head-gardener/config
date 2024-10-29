{ alloy, lib, ... }:
{
  networking.firewall.allowedTCPPorts =
    lib.mkIf (alloy.nginx.address != alloy.grafana.address) [ 2342 ];

  services.grafana = {
    enable = true;
    settings = {
      log.level = "warn";

      server = {
        domain = "${alloy.grafana.hostname}.wg";
        http_port = 2342;
        http_addr =
          if (alloy.nginx.address != alloy.grafana.address)
            then alloy.grafana.address
          else "127.0.0.1";
      };
    };
  };
}
