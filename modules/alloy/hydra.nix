{ alloy, lib, config, pkgs, ... }:
{
  options = {
    services.hydra = {
      endpoint = lib.mkOption { type = lib.types.str; };
      metricsPort = lib.mkOption {
        type = lib.types.port;
        default = 9198;
      };
    };
  };

  config = {
    networking.firewall.allowedTCPPorts = lib.mkMerge
      [ (lib.mkIf (alloy.nginx.address != alloy.hydra.address) [ 3000 ])
        [ config.services.hydra.metricsPort ]
      ];

    services.hydra = rec {
      endpoint = "hydra.backyard-hg.xyz";
      metricsPort = 9198;

      enable = true;
      hydraURL = "https://${endpoint}";
      notificationSender = "hydra@localhost";
      useSubstitutes = true;
      extraConfig = ''
        queue_runner_metrics_address = [::]:${toString metricsPort}
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
