{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 4000 ];

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = { };
    scrapeConfigs = [
      {
        job_name = "hydra";
        static_configs = [{
          targets = [ "127.0.0.1:3000" ];
        }];
      }
      {
        job_name = "cherry";
        static_configs = [{
          targets = [ "cherry:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
      {
        job_name = "blueberry";
        static_configs = [{
          targets = [ "blueberry:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };
}