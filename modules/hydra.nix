{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 3000 9198 ];

  services.hydra = {
    enable = true;
    hydraURL = "http://hydra:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    extraConfig = ''
      queue_runner_metrics_address = [::]:9198
    '';
  };

  nix.buildMachines = [
    {
      hostName = "localhost";
      inherit (pkgs) system;
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
