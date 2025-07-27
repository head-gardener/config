{ alloy, net, config, ... }:
{
  networking.firewall.interfaces.wg0.allowedTCPPorts =
    [ config.services.grafana.settings.server.http_port ];

  personal.mappings."grafana.local".nginx = {
    enable = true;
    port = config.services.grafana.settings.server.http_port;
  };

  services.grafana = {
    enable = true;
    settings = {
      log.level = "warn";

      server = {
        domain = "grafana.local";
        http_port = 2342;
        http_addr = net.self.ipv4;
      };
    };
  };
}
