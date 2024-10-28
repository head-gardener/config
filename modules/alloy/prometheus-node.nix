{
  imports = [
    ../loki.nix
  ];

  networking.firewall.interfaces.wg0.allowedTCPPorts = [ 4000 ];

  services.prometheus = {
    enable = true;
    port = 4000;
    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 4001;
      };
    };
  };
}
