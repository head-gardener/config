{ alloy, lib, pkgs, config, inputs, ... }: {
  options = {
    services.wg = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 43721;
      };
      isClient = lib.mkOption { type = lib.types.bool; };
    };
  };

  config =
  let
    cfg = config.services.wg;
    hosts = builtins.fromJSON (builtins.readFile "${inputs.self}/hosts.json");
  in {
    age.secrets.wg = {
      file = "${inputs.self}/secrets/wg/${config.networking.hostName}.age";
    };

    networking.wireguard.enable = true;
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    environment.systemPackages = [ pkgs.wireguard-tools ];

    networking.firewall.trustedInterfaces = [ "wg0" ];

    networking.wg-quick.interfaces = {
      wg0 = {
        address = [ hosts."${config.networking.hostName}".ipv4 ];
        listenPort = cfg.port;
        privateKeyFile = config.age.secrets.wg.path;
        peers = lib.mkMerge [
          (lib.mkIf cfg.isClient [{
            publicKey = hosts."${alloy.wireguard-server.hostname}".publicKey;
            endpoint = "93.125.3.204:${toString cfg.port}";
            allowedIPs = [ hosts."${alloy.wireguard-server.hostname}".ipv4 ];
          }])
          (lib.mkIf (!cfg.isClient) (alloy.wireguard-client.forEach (host: {
            publicKey = hosts."${host.hostname}".publicKey;
            allowedIPs = [ hosts."${host.hostname}".ipv4 ];
          })))
        ];
      };
    };
  };
}
