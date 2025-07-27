{ lib, config, pkgs, ... }: {
  options.services.dnsmasq = {
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    dynamic-interfaces = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    additional-hosts = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          address = lib.mkOption { type = lib.types.str; };
          name = lib.mkOption { type = lib.types.str; };
        };
      });
      default = [ ];
    };
  };

  config = let
    hosts-file = pkgs.writeText "dnsmasq-addn-hosts"
      (builtins.concatStringsSep "\n" (map (h: "${h.address} ${h.name}")
        config.services.dnsmasq.additional-hosts));
  in {
    services.dnsmasq.settings = {
      bind-dynamic = lib.mkIf config.services.dnsmasq.dynamic-interfaces true;
      bind-interfaces =
        lib.mkIf (!config.services.dnsmasq.dynamic-interfaces) true;
      interface = lib.mkIf config.services.dnsmasq.enable
        (lib.concatStringsSep "," config.services.dnsmasq.interfaces);
      addn-hosts = "${hosts-file}";
    };
  };
}
