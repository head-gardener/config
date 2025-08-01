{ alloy, config, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 4000 ];

  personal.mappings."prometheus.local".nginx = {
    enable = true;
    port = config.services.prometheus.port;
  };

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
        job_name = "jenkins";
        static_configs = [{
          targets = [
            "${alloy.jenkins-mono.address}:${toString alloy.jenkins-mono.config.services.jenkins.port}"
          ];
        }];
        metrics_path = "prometheus/";
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
        static_configs = with host.config.services.prometheus; [{
          targets = lib.mkMerge [
            [ "${host.hostname}.wg:${toString exporters.node.port}" ]
            (lib.mkIf (exporters.smartctl.enable)
              [ "${host.hostname}.wg:${toString exporters.smartctl.port}" ])
          ];
        }];
      }));
  };
}
