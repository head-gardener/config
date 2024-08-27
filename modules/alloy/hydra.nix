{ alloy, lib, config, pkgs, ... }:
{
  options = {
    services.hydra.endpoint = lib.mkOption { type = lib.types.str; };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.mkMerge
      [ (lib.mkIf (alloy.nginx.host != alloy.hydra.host) [ 3000 ])
        [ 9198 ]
      ];

    services.hydra = rec {
      endpoint = "hydra.backyard-hg.xyz";

      enable = true;
      hydraURL = "https://${endpoint}";
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
  };
}
