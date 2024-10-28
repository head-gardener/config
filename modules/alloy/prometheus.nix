{ alloy, ... }:
{
  networking.firewall.allowedTCPPorts = [ 4000 ];

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = { };
    scrapeConfigs = [
      {
        job_name = "nginx";
        static_configs = [{
          targets = [
            "${alloy.nginx.address}:${toString alloy.nginx.config.services.prometheus.exporters.nginx.port}"
          ];
        }];
      }
      {
        job_name = "loki";
        static_configs = [{
          targets = [
            "${alloy.loki.hostname}.wg:${toString alloy.loki.config.services.loki.configuration.server.http_listen_port}"
          ];
        }];
      }
    ] ++ (alloy.prometheus-node.forEach (host:
      {
        job_name = host.hostname;
        static_configs = [{
          targets = [
            "${host.hostname}.wg:${toString host.config.services.prometheus.exporters.node.port}"
          ];
        }];
      }));
  };
}
