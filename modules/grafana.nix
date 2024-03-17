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
}
