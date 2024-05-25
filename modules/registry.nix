{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ config.services.dockerRegistry.port ];

  services.dockerRegistry = {
    enable = true;
    listenAddress = "0.0.0.0";
  };
}
