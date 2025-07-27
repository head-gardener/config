{ alloy, inputs, lib, config, net, pkgs, ... }: {
  imports = [ inputs.self.nixosModules.docker ];

  networking.nat = { enable = true; };

  personal.mappings."jenkins.local".nginx = {
    enable = true;
    port = config.services.jenkins.port;
  };

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
      credentials = {
        system = {
          domainCredentials = [{ domain = { name = "verification"; }; }];
        };
      };
      jenkins = {
        authorizationStrategy = {
          loggedInUsersCanDoAnything = { allowAnonymousRead = false; };
        };
        crumbIssuer = { standard = { excludeClientIPFromCrumb = false; }; };
        disableRememberMe = false;
        disabledAdministrativeMonitors = [ "hudson.util.DoubleLaunchChecker" ];
        labelAtoms = [
          { name = "built-in"; }
          { name = "container"; }
          { name = "docker"; }
          { name = "linux"; }
          { name = "master"; }
          { name = "nats"; }
          { name = "nix"; }
        ];
        labelString = "master";
        markupFormatter = "plainText";
        mode = "EXCLUSIVE";
        myViewsTabBar = "standard";
        nodeMonitors = [
          "architecture"
          "clock"
          {
            diskSpace = {
              freeSpaceThreshold = "1GiB";
              freeSpaceWarningThreshold = "2GiB";
            };
          }
          "swapSpace"
          {
            tmpSpace = {
              freeSpaceThreshold = "1GiB";
              freeSpaceWarningThreshold = "2GiB";
            };
          }
          "responseTime"
        ];
        nodes = [{
          permanent = {
            labelString = "linux nix nats docker";
            launcher = {
              inbound = {
                workDirSettings = {
                  disabled = false;
                  failIfWorkDirIsMissing = true;
                  internalDir = "remoting";
                };
              };
            };
            name = "container";
            nodeProperties = [{
              diskSpaceMonitor = {
                freeDiskSpaceThreshold = "100MiB";
                freeDiskSpaceWarningThreshold = "200MiB";
                freeTempSpaceThreshold = "50MiB";
                freeTempSpaceWarningThreshold = "100MiB";
              };
            }];
            numExecutors = 2;
            remoteFS = "/var/lib/jenkins";
            retentionStrategy = "always";
          };
        }];
        numExecutors = 0;
        primaryView = { all = { name = "all"; }; };
        projectNamingStrategy = "standard";
        quietPeriod = 5;
        remotingSecurity = { enabled = true; };
        scmCheckoutRetryCount = 0;
        securityRealm = {
          local = {
            allowsSignup = false;
            enableCaptcha = false;
            users = [{
              id = "hunter";
              name = "hunter";
              properties = [
                "apiToken"
                "consoleUrlProvider"
                { mailer = { emailAddress = "trashbin2019np@gmail.com"; }; }
                { preferredProvider = { providerId = "default"; }; }
                "experimentalFlags"
                { theme = { theme = "dark"; }; }
              ];
            }];
          };
        };
        slaveAgentPort = 10000;
        systemMessage = ''
          Jenkins configured automatically by Jenkins Configuration as Code plugin

        '';
        updateCenter = {
          sites = [{
            id = "default";
            url = "https://updates.jenkins.io/update-center.json";
          }];
        };
        views = [{ all = { name = "all"; }; }];
        viewsTabBar = "standard";
      };
      globalCredentialsConfiguration = {
        configuration = {
          providerFilter = "none";
          typeFilter = "none";
        };
      };
      appearance = {
        prism = { theme = "PRISM"; };
        themeManager = { disableUserThemes = false; };
      };
      security = {
        apiToken = {
          creationOfLegacyTokenEnabled = false;
          tokenGenerationOnCreationEnabled = false;
          usageStatisticsEnabled = true;
        };
        cps = { hideSandbox = false; };
        gitHooks = {
          allowedOnAgents = false;
          allowedOnController = false;
        };
        gitHostKeyVerificationConfiguration = {
          sshHostKeyVerificationStrategy = "knownHostsFileVerificationStrategy";
        };
        sSHD = { port = -1; };
        scriptApproval = {
          approvedScriptHashes = [
            "SHA512:cb8c72eef710af200cd3b7e7003b630a87127bf256aefc483806939c7d7aa56677294e0b72ad6976ddb9375958102908371beb565dbffd5e0a210d5dcfdcd2bf"
          ];
          forceSandbox = false;
        };
      };
      unclassified = {
        buildDiscarders = {
          configuredBuildDiscarders = [ "jobBuildDiscarder" ];
        };
        buildStepOperation = { enabled = false; };
        email-ext = {
          adminRequiredForTemplateTesting = false;
          allowUnregisteredEnabled = false;
          charset = "UTF-8";
          debugMode = false;
          defaultBody = ''
            $PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:

                  Check console output at $BUILD_URL to view the results.'';
          defaultContentType = "text/plain";
          defaultSubject =
            "$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!";
          defaultTriggerIds =
            [ "hudson.plugins.emailext.plugins.trigger.FailureTrigger" ];
          maxAttachmentSize = -1;
          maxAttachmentSizeMb = -1;
          precedenceBulk = false;
          throttlingEnabled = false;
          watchingEnabled = false;
        };
        fingerprints = {
          fingerprintCleanupDisabled = false;
          storage = "file";
        };
        gitHubConfiguration = { apiRateLimitChecker = "ThrottleForNormalize"; };
        gitHubPluginConfig = {
          hookUrl = "http://jenkins.local/github-webhook/";
        };
        globalTimeOutConfiguration = {
          operations = [ "abortOperation" ];
          overwriteable = false;
        };
        junitTestResultStorage = { storage = "file"; };
        location = {
          adminAddress = "address not configured yet <nobody@nowhere>";
          url = "http://jenkins.local/";
        };
        mailer = {
          charset = "UTF-8";
          useSsl = false;
          useTls = false;
        };
        pollSCM = { pollingThreadCount = 10; };
        prometheusConfiguration = {
          appendParamLabel = false;
          appendStatusLabel = false;
          collectCodeCoverage = false;
          collectDiskUsage = true;
          collectNodeStatus = true;
          collectingMetricsPeriodInSeconds = 120;
          countAbortedBuilds = true;
          countFailedBuilds = true;
          countNotBuiltBuilds = true;
          countSuccessfulBuilds = true;
          countUnstableBuilds = true;
          defaultNamespace = "default";
          fetchTestResults = true;
          jobAttributeName = "jenkins_job";
          path = "prometheus";
          perBuildMetrics = false;
          processingDisabledBuilds = false;
          useAuthenticatedEndpoint = false;
        };
        scmGit = {
          addGitTagAction = false;
          allowSecondFetch = false;
          createAccountBasedOnEmail = false;
          disableGitToolChooser = false;
          hideCredentials = false;
          showEntireCommitSummaryInChanges = false;
          useExistingAccountWithSameEmail = false;
        };
        timestamper = {
          allPipelines = false;
          elapsedTimeFormat = "'<b>'HH:mm:ss.S'</b> '";
          systemTimeFormat = "'<b>'HH:mm:ss'</b> '";
        };
      };
      tool = {
        git = {
          installations = [{
            home = "git";
            name = "Default";
          }];
        };
        mavenGlobalConfig = {
          globalSettingsProvider = "standard";
          settingsProvider = "standard";
        };
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
