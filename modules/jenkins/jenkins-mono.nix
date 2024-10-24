{ inputs, lib, config, pkgs, ... }: {
  imports = [ ../container-host.nix ];

  age.secrets.jenkins-slave-secret = {
    file = "${inputs.self}/secrets/jenkins-slave-secret.age";
    owner = "jenkins";
    group = "jenkins";
  };

  networking.firewall.allowedTCPPorts = [ config.services.jenkins.port ];

  services.jenkins = let
    cfg = lib.generators.toYAML { } {
      jenkins = {
        nodes = [{
          permanent = {
            name = "container";
            labelString = "linux nix";
            remoteFS = "/var/lib/jenkins";
            retentionStrategy = "always";
            numExecutors = 2;

            nodeProperties = [{
              diskSpaceMonitor = {
                freeDiskSpaceThreshold = "100MiB";
                freeDiskSpaceWarningThreshold = "200MiB";
                freeTempSpaceThreshold = "50MiB";
                freeTempSpaceWarningThreshold = "100MiB";
              };
            }];

            launcher.inbound.workDirSettings = {
              disabled = false;
              failIfWorkDirIsMissing = true;
              internalDir = "remoting";
            };
          };
        }];

        slaveAgentPort = 10000;
        numExecutors = 0;
        agentProtocols = [ "JNLP4-connect" ];
      };
    };
  in {
    enable = true;
    withCLI = true;
    port = 8080;
    environment = {
      CASC_JENKINS_CONFIG = "${pkgs.writeText "jenkins.yaml" cfg}";
    };
    extraJavaOptions = [
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
  };

  systemd.services."container@jenkins-slave".after = [ "jenkins.service" ];

  containers.jenkins-slave = {
    autoStart = true;
    restartIfChanged = true;
    ephemeral = true;

    privateNetwork = true;
    hostAddress = "192.168.100.1";
    localAddress = "192.168.100.200";

    bindMounts = {
      # This only works because nspawn gives container's users same uids or something
      "/run/secrets/jenkins-slave-secret" = {
        hostPath = config.age.secrets.jenkins-slave-secret.path;
      };
    };

    config = let
      inherit (config.services.jenkins) port;
      inherit (config.containers.jenkins-slave) hostAddress;
    in ({ config, ... }: {
      imports = [ ../default/nix-minimal.nix ];

      services.jenkinsSlave.enable = true;

      systemd.services.jenkins-slave = {
        enable = true;

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          User = "jenkins";
          Group = "jenkins";

          WorkingDirectory = config.services.jenkinsSlave.home;
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 3;
        };

        path = with pkgs; [
          bash
          config.services.jenkinsSlave.javaPackage
          curl
          git
          nix
        ];

        script = let address = "${hostAddress}:${toString port}";
        in ''
          # TODO: fix this
          curl -O http://${address}/jnlpJars/agent.jar
          java -jar agent.jar -url http://${address}/ -secret "$(cat /run/secrets/jenkins-slave-secret)" -name container -workDir "${config.services.jenkinsSlave.home}"
        '';
      };

      networking.useHostResolvConf = true;

      boot.isContainer = true;
    });
  };
}
