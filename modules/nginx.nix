{ config, inputs, ... }: {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "trashbin2019np@gmail.com";
    };
  };

  age.secrets.cache = {
    file = "${inputs.self}/secrets/cache.age";
  };

  services = {
    nix-serve = {
      enable = true;
      secretKeyFile = config.age.secrets.cache.path;
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

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = {
      nginx = {
        enable = true;
        openFirewall = true;
        port = 9113;
      };
    };
  };

  services.nginx = {
    enable = true;

    statusPage = true;

    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;

    appendHttpConfig = ''
      # Minimize information leaked to other domains
      add_header 'Referrer-Policy' 'origin-when-cross-origin';

      # Disable embedding as a frame
      add_header X-Frame-Options DENY;

      # Prevent injection of code in other mime types (XSS Attacks)
      add_header X-Content-Type-Options nosniff;
    '';

    commonHttpConfig = "limit_req_zone $binary_remote_addr zone=common:10m rate=10r/s;";
    virtualHosts = rec {
      "grafana.backyard-hg.xyz" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://127.0.0.1:2342";
        };
      };

      "s3.backyard-hg.xyz" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://cherry:9000";
        };
        extraConfig = ''
          # s3fs can exceed the limit sometimes
          client_max_body_size 20m;
        '';
      };

      "cache.backyard-hg.xyz" = blueberry // {
        enableACME = true;
        forceSSL = true;
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
