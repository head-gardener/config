{ config, ... }:
{
  networking.firewall.allowedTCPPorts = [ 3000 ];
  services.hydra = {
    enable = true;
    hydraURL = "http://hydra:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
  };

  nix.buildMachines = [
    {
      hostName = "localhost";
      system = "x86_64-linux";
      supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
      maxJobs = 8;
    }
  ];

  services.postgresql.enable = true;

  services.nginx.virtualHosts."hydra.backyard-hg.xyz" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      recommendedProxySettings = true;
      proxyPass = config.services.hydra.hydraURL;
    };
  };
}
