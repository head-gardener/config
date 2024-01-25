{ config, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "trashbin2019np@gmail.com";
    };
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = "/home/hunter/nix-serve/cache-priv.pem";
    };
  };

  services.blog = {
    enable = true;
    host = "backyard-hg.xyz";
    vhostConfig = {
      enableACME = true;
      forceSSL = true;
      # extraConfig = "limit_req zone=common;";
    };
  };

  services.nginx = {
    enable = true;
    commonHttpConfig = "limit_req_zone $binary_remote_addr zone=common:10m rate=10r/s;";
    virtualHosts = rec {
      "cache.backyard-hg.xyz" = blueberry;
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
