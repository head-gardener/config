{ alloy, net, lib, pkgs, config, inputs, ... }: {
  options = {
    personal.wg = {
      port = lib.mkOption {
        type = lib.types.port;
        default = 43721;
      };
      isClient = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      interface = lib.mkOption {
        type = lib.types.str;
        default = "wg0";
      };
      service = lib.mkOption {
        readOnly = true;
        type = lib.types.str;
        default = "wg-quick-${config.personal.wg.interface}.service";
      };
    };
  };

  config = let
    cfg = config.personal.wg;
    server = net.hosts."${alloy.wireguard-server.hostname}";

  in {
    age.secrets.wg = {
      file = "${inputs.self}/secrets/wg/${config.networking.hostName}.age";
    };

    environment.systemPackages = [ pkgs.wireguard-tools ];

    # TODO: no
    networking.firewall.trustedInterfaces = [ cfg.interface ];
    networking.firewall.allowedUDPPorts = [ cfg.port ];

    networking.nat = lib.mkIf (!cfg.isClient) {
      enable = true;
      internalInterfaces = [ cfg.interface ];
    };

    # TODO: restart trigger
    services.dnsmasq = lib.mkIf (!cfg.isClient) {
      enable = true;
      interfaces = [ cfg.interface ];
      additional-hosts = map (h: {
        address = h.value.ipv4;
        name = "${h.name}.wg";
      }) (lib.attrsToList net.hosts);
      settings = { no-hosts = true; };
    };

    personal.polkit.allowUnitControl."wg-quick-${config.personal.wg.interface}.service".groups =
      lib.mkIf (cfg.isClient) [ "wg-quick-${config.personal.wg.interface}-ctl" ];
    users.groups."wg-quick-${config.personal.wg.interface}-ctl" = { };

    networking.wg-quick.interfaces.${cfg.interface} = {
      address = [ "${net.self.ipv4}/24" ];
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
            | ${
              lib.getExe config.networking.resolvconf.package
            } -a ${cfg.interface}
        ''
      ];

      preDown = lib.mkMerge [
        (lib.mkIf (!cfg.isClient) ''
          ${pkgs.iptables}/bin/iptables -D FORWARD -i ${cfg.interface} -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${server.ipv4}/24 -o enp2s0 -j MASQUERADE
        '')
        ''
          ${
            lib.getExe config.networking.resolvconf.package
          } -d ${cfg.interface} -f
        ''
      ];

      peers = lib.mkMerge [
        (lib.mkIf cfg.isClient [{
          publicKey = server.publicKey;
          endpoint = "93.125.3.204:${toString cfg.port}";
          persistentKeepalive = 25;
          allowedIPs = [ "${server.ipv4}/24" ];
        }])
        (lib.mkIf (!cfg.isClient) (alloy.wireguard-client.forEach (host: {
          publicKey = net.hosts."${host.hostname}".publicKey;
          allowedIPs = [ "${net.hosts."${host.hostname}".ipv4}/32" ];
        })))
      ];
    };
  };
}
