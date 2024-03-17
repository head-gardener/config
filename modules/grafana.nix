{ config, ... }:
{
  services.grafana = {
    enable = true;
    settings.server = {
      domain = "backyard-hg.xyz";
      http_port = 2342;
      http_addr = "127.0.0.1";
    };
  };

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 4001;
      };
    };
    scrapeConfigs = [
      {
        job_name = config.networking.hostName;
        static_configs = [{
          targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.node.port}" ];
        }];
      }
    ];
  };
}
