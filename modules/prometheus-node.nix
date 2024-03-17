{
  networking.firewall.allowedTCPPorts = [ 4000 4001 ];

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
