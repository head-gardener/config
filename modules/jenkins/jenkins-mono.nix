{ alloy, inputs, lib, config, net, pkgs, ... }: {
  imports = [ inputs.self.nixosModules.docker ];

  networking.nat = { enable = true; };

  personal.va.templates.jenkins-slave = {
    path = "services/jenkins/slave";
    field = "secret";
    owner = "jenkins";
    group = "jenkins";
    for = "container@jenkins-slave.service";
  };

  networking.firewall.allowedTCPPorts = [ config.services.jenkins.port ];
  networking.firewall.trustedInterfaces = [ "ve-*" ];

  services.jenkins = let
    cfg = lib.generators.toYAML { } {
      jenkins = {
        nodes = [{
          permanent = {
            name = "container";
            labelString = "linux nix nats docker";
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

  systemd.services."container@j-slave".after = [ "jenkins.service" ];

  # libvirt probably overrides this so zero clue if it works
  systemd.services."container@j-slave".preStart = ''
    ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -o enp2s0 -j MASQUERADE
    ${pkgs.iptables}/bin/iptables -A FORWARD -i enp2s0 -o ve-j-slave -j ACCEPT
    ${pkgs.iptables}/bin/iptables -A FORWARD -i ve-j-slave -o enp2s0 -j ACCEPT
  '';
  systemd.services."container@j-slave".postStop = ''
    ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -o enp2s0 -j MASQUERADE
    ${pkgs.iptables}/bin/iptables -D FORWARD -i enp2s0 -o ve-j-slave -j ACCEPT
    ${pkgs.iptables}/bin/iptables -D FORWARD -i ve-j-slave -o enp2s0 -j ACCEPT
  '';

  services.dnsmasq = {
    enable = true;
    interfaces = [ "ve-j-slave" ];
    dynamic-interfaces = true;
  };

  containers.j-slave = {
    autoStart = true;
    restartIfChanged = true;
    ephemeral = true;

    privateNetwork = true;
    hostAddress = "192.168.100.1";
    localAddress = "192.168.100.200";

    bindMounts = {
      # This only works because nspawn gives container's users same uids or something
      "/run/secrets/jenkins-slave-secret" = {
        hostPath = config.personal.va.templates.jenkins-slave.destination;
      };
      "/var/run/docker.sock" = { hostPath = "/var/run/docker.sock"; };
    };

    config = let
      inherit (config.services.jenkins) port;
      inherit (config.containers.j-slave) hostAddress;
      dockerGID = config.ids.gids.docker;
    in ({ config, ... }: {
      imports = [ inputs.self.nixosModules.nix-minimal ];

      services.jenkinsSlave.enable = true;

      users.users.jenkins.extraGroups = [ "docker" ];

      users.groups.docker.gid = dockerGID;

      systemd.services.j-slave = {
        enable = true;

        wantedBy = [ "multi-user.target" ];
        wants = [ "network-online.target" ];

        environment = { NATS_SERVER = net.hosts.${alloy.nats.hostname}.ipv4; };

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
          docker
          git
          lix
          natscli
        ];

        script = let address = "${hostAddress}:${toString port}";
        in ''
          # TODO: fix this
          curl -O http://${address}/jnlpJars/agent.jar
          java -jar agent.jar -url http://${address}/ -secret "$(cat /run/secrets/jenkins-slave-secret)" -name container -workDir "${config.services.jenkinsSlave.home}"
        '';
      };

      networking.useHostResolvConf = false;
      networking.useDHCP = false;
      networking.nameservers = [ hostAddress ];

      boot.isContainer = true;
    });
  };
}
