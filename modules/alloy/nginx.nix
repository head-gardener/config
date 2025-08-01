{ alloy, net, ... }:
let
  serviceToAddress = svc:
    "http://${alloy.${svc}.address}:${
      toString alloy.${svc}.config.services.${svc}.port
    }";
in {
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "trashbin2019np@gmail.com";
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

    commonHttpConfig =
      "limit_req_zone $binary_remote_addr zone=common:10m rate=10r/s;";

    defaultListenAddresses = [ "0.0.0.0" ];

    virtualHosts = rec {
      "s3.backyard-hg.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = "http://${alloy.minio.address}:9000";
        };
        extraConfig = ''
          # s3fs can exceed the limit sometimes
          client_max_body_size 20m;
        '';
      };

      ${alloy.nix-serve.config.services.nix-serve.endpoint} = blueberry // {
        enableACME = true;
        forceSSL = true;
      };

      "192.168.1.102" = blueberry;
      blueberry = {
        locations."/" = {
          recommendedProxySettings = true;
          proxyPass = serviceToAddress "nix-serve";
        };
      };
    };
  };
}
