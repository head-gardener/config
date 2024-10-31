{ net, config, ... }:
{
  networking.firewall.interfaces.wg0.allowedTCPPorts =
    [ config.services.grafana.settings.server.http_port ];

  services.grafana = {
    enable = true;
    settings = {
      log.level = "warn";

      server = {
        domain = "${config.networking.hostName}.wg";
        http_port = 2342;
        http_addr = net.self.ipv4;
      };
    };
  };
}
