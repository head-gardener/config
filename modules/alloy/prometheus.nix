{ config, alloy, ... }:
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
        job_name = "hydra";
        static_configs = [{
          targets = [
            "${alloy.hydra.address}:3000"
            "${alloy.hydra.address}:${toString alloy.hydra.config.services.hydra.metricsPort}"
          ];
        }];
      }
    ] ++ (alloy.prometheus-node.forEach (host:
      {
        job_name = host.hostname;
        static_configs = [{
          targets = [
            "${host.address}:${toString host.config.services.loki.configuration.server.http_listen_port}"
            "${host.address}:${toString host.config.services.prometheus.exporters.node.port}"
          ];
        }];
      }));
  };
}
