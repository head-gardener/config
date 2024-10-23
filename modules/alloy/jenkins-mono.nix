{ inputs, config, pkgs, ... }: {
  imports = [ ../container-host.nix ];

  age.secrets.jenkins-slave-secret = {
    file = "${inputs.self}/secrets/jenkins-slave-secret.age";
  };

  networking.firewall.allowedTCPPorts = [ config.services.jenkins.port ];

  services.jenkins = {
    enable = true;
    withCLI = true;
    port = 8080;
    extraJavaOptions = [
      "-Dorg.jenkinsci.plugins.durabletask.BourneShellScript.LAUNCH_DIAGNOSTICS=true"
    ];
  };

  systemd.services."continer@jenkins-slave".after = [ "jenkins.service" ];

  containers.jenkins-slave = {
    autoStart = true;
    restartIfChanged = true;
    ephemeral = true;

    privateNetwork = true;
    hostAddress = "192.168.100.1";
    localAddress = "192.168.100.200";

    bindMounts = {
      "/run/secrets/jenkins-slave-secret" = {
        hostPath = config.age.secrets.jenkins-slave-secret.path;
        isReadOnly = true;
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

        wantedBy = [ "timers.target" ];
        wants = [ "network-online.target" ];

        serviceConfig = {
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 3;
        };

        path = with pkgs; [
          bash
          config.services.jenkinsSlave.javaPackage
          curl
          git
        ];

        script = let address = "${hostAddress}:${toString port}";
        in ''
          curl -O http://${address}/jnlpJars/agent.jar
          java -jar agent.jar -url http://${address}/ -secret "$(cat /run/secrets/jenkins-slave-secret)" -name container -workDir "/var/lib/jenkins"
        '';
      };

      networking.useHostResolvConf = true;

      boot.isContainer = true;
    });
  };
}
