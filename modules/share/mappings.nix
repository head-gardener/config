{ net, config, lib, ... }:
let
  inherit (lib) mkOption types;

  cfg = config.personal.mappings;
in {

  options.personal.mappings = mkOption {
    type = types.attrsOf (types.submodule {
      options = {
        address = lib.mkOption {
          type = types.str;
          default = net.self.ipv4;
          description = lib.mkDoc ''
            VPN address of the host. Defaults to current host's address.
            Will be overriden with nginx host's address if nginx virtual
            host is enabled.
          '';
        };

        nginx = {
          enable = lib.mkOption {
            type = types.bool;
            default = false;
            description = lib.mkDoc ''
              Whether to create nginx virtual host entry for this host.
            '';
          };

          address = lib.mkOption {
            type = types.str;
            default = net.self.ipv4;
            description = lib.mkDoc ''
              Service address, accessible from VPN.
            '';
          };

          port = lib.mkOption {
            type = types.port;
            description = lib.mkDoc ''
              Service port.
            '';
          };

          proto = lib.mkOption {
            type = types.str;
            default = "http";
            description = lib.mkDoc ''
              Proxy proto. HTTP is default.
            '';
          };

          extraConfig = lib.mkOption {
            type = types.attrsOf types.raw;
            default = { };
            description = lib.mkDoc ''
              Extra virtual host config.
            '';
          };
        };
      };
    });
    default = { };
    description = lib.mdDoc ''
      Host mappings to make accessible inside the VPN.
    '';
  };

  config = lib.mkIf (lib.length (lib.attrsToList cfg) != 0) {
    alloy.extend.dnsmasq = [
      ({ net, ... }: {
        services.dnsmasq.additional-hosts = lib.mapAttrsToList (n: v: {
          address = if v.nginx.enable then net.self.ipv4 else v.address;
          name = n;
        }) cfg;
      })
    ];

    alloy.extend.nginx = [
      ({ net, ... }: {
        services.nginx.virtualHosts = lib.mapAttrs (n: v: {
          enableACME = false;
          forceSSL = false;
          listenAddresses = [ net.self.ipv4 ];
          locations."/" = {
            recommendedProxySettings = true;
            proxyPass =
              "${v.nginx.proto}://${v.nginx.address}:${toString v.nginx.port}";
          } // v.nginx.extraConfig;
        }) (lib.filterAttrs (_: v: v.nginx.enable) cfg);
      })
    ];

  };

}
