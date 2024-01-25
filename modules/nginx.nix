{ config, ... }: {
  services.blog = {
    enable = true;
    host = "backyard-hg.xyz";
    vhostConfig = {
      enableACME = true;
      forceSSL = true;
      extraConfig = "limit_req zone=common;";
    };
  };

  services.nginx = {
    enable = true;
    commonHttpConfig = "limit_req_zone $binary_remote_addr zone=common:10m rate=10r/s;";
    virtualHosts = rec {
      "93.125.3.204" = {
        locations = {
          "/" = {
            root = "/drive-d/";
            extraConfig = ''
              autoindex on;
              limit_req zone=common;
            '';
            basicAuth = { dina = "17133678592"; };
          };
        };
      };

      "192.168.1.102" = blueberry;
      blueberry = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass =
            "http://${config.services.nix-serve.bindAddress}:${toString config.services.nix-serve.port}";
        };
      };
    };
  };
}
