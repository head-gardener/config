{ alloy, lib, pkgs, config, inputs, ... }: {
  options = {
    services.wg = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 43721;
      };
      isClient = lib.mkOption { type = lib.types.bool; };
      interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
      };
    };
  };

  config = let
    cfg = config.services.wg;
    hosts = builtins.fromJSON (builtins.readFile "${inputs.self}/hosts.json");
    server = hosts."${alloy.wireguard-server.hostname}";
    hosts-file = pkgs.writeText "dnsmasq-wg-hosts"
      (builtins.concatStringsSep "\n"
        (map (h: "${h.value.ipv4} ${h.name}.wg") (lib.attrsToList hosts)));

  in {
    age.secrets.wg = {
      file = "${inputs.self}/secrets/wg/${config.networking.hostName}.age";
    };

    environment.systemPackages = [ pkgs.wireguard-tools ];

    networking.wireguard.enable = true;
    networking.firewall.allowedUDPPorts = [ cfg.port ];
    networking.firewall.trustedInterfaces = [ "wg0" ];

    networking.nat = lib.mkIf (!cfg.isClient) {
      enable = true;
      internalInterfaces = [ "wg0" ];
    };

    # TODO: restart trigger
    services.dnsmasq = lib.mkIf (!cfg.isClient) {
      enable = true;
      settings = {
        interface = "wg0";
        no-hosts = true;
        addn-hosts = "${hosts-file}";
      };
    };

    networking.wg-quick.interfaces.${cfg.interface} = {
      address = [ "${hosts."${config.networking.hostName}".ipv4}/24" ];
      listenPort = cfg.port;
      privateKeyFile = config.age.secrets.wg.path;

      # TODO: review these once i get good with iptables
      postUp = lib.mkMerge [
        (lib.mkIf (!cfg.isClient) ''
          ${pkgs.iptables}/bin/iptables -A FORWARD -i ${cfg.interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${server.ipv4}/24 -o enp2s0 -j MASQUERADE
        '')
        ''
          echo 'nameserver ${server.ipv4}' \
            | ${lib.getExe config.networking.resolvconf.package} -a ${cfg.interface}
        ''
      ];

      preDown = lib.mkMerge [(lib.mkIf (!cfg.isClient) ''
        ${pkgs.iptables}/bin/iptables -D FORWARD -i ${cfg.interface} -j ACCEPT
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${server.ipv4}/24 -o enp2s0 -j MASQUERADE
      '')
      ''
        ${lib.getExe config.networking.resolvconf.package} -d ${cfg.interface} -f
      ''];

      peers = lib.mkMerge [
        (lib.mkIf cfg.isClient [{
          publicKey = server.publicKey;
          endpoint = "93.125.3.204:${toString cfg.port}";
          persistentKeepalive = 25;
          allowedIPs = [ "${server.ipv4}/24" ];
        }])
        (lib.mkIf (!cfg.isClient) (alloy.wireguard-client.forEach (host: {
          publicKey = hosts."${host.hostname}".publicKey;
          allowedIPs = [ "${hosts."${host.hostname}".ipv4}/32" ];
        })))
      ];
    };
  };
}
