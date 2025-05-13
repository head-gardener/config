{ lib, config, ... }: {
  options.services.dnsmasq = {
    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
    dynamic-interfaces = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = {
    services.dnsmasq.settings.bind-dynamic = lib.mkIf config.services.dnsmasq.dynamic-interfaces true;
    services.dnsmasq.settings.bind-interfaces = lib.mkIf (! config.services.dnsmasq.dynamic-interfaces) true;
    services.dnsmasq.settings.interface =
      lib.mkIf config.services.dnsmasq.enable
      (lib.concatStringsSep "," config.services.dnsmasq.interfaces);
  };
}
