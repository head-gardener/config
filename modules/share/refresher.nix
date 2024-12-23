{ config, lib, pkgs, ... }:

let

  inherit (lib) mkOption mkIf types;

  githubHK = ''
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  mkServices = suffix: cfg:
    let
      updateCmd = (if lib.length cfg.inputs == 0
      then "${lib.getExe pkgs.nix} flake update --commit-lock-file "
      else "${lib.getExe pkgs.nix} flake lock --commit-lock-file ")
      + lib.concatMapStrings (x: " --update-input " + x) cfg.inputs;

      sshCmd = "${lib.getExe pkgs.openssh} -i $CREDENTIALS_DIRECTORY/ID -F ${pkgs.writeText "ssh_config" sshConfig}";

      sshConfig = ''
        StrictHostKeyChecking=accept-new
        UserKnownHostsFile=${pkgs.writeText "known_hosts" githubHK}
        ${cfg.extraSSHConf}
      '';

      name = "refresher" + (if lib.isString suffix then "-" + suffix else "");

      ifStaging = s: lib.optionalString cfg.staging s;

      script = ''
        git clone ${cfg.repo} . --depth 1 ${ifStaging "--single-branch --branch staging"}
        ${ifStaging ''
          git switch --detach
          git fetch origin master
          git branch -f staging FETCH_HEAD
          git switch staging
        ''}
        ${updateCmd}
        git push -f
      '';
    in
    mkIf cfg.enable {
      services.${name} = {
        description = "Remote flake input updater"
          + (if lib.isString suffix then ", suffix: ${suffix}" else "");
        path = [ pkgs.git ];

        environment = {
          HOME = "/run/${name}";
          GIT_SSH_COMMAND = sshCmd;
          GIT_AUTHOR_NAME = cfg.authorName;
          GIT_COMMITTER_NAME = cfg.authorName;
          EMAIL = cfg.authorEmail;
        };

        inherit script;

        serviceConfig = {
          LoadCredential = "ID:${cfg.identity}";
          RuntimeDirectory = name;
          DynamicUser = true;
          WorkingDirectory = "/run/${name}";
          Type = "oneshot";
          User = name;
        };
      };

      timers.${name} = {
        description = "Remote flake input updater"
          + (if lib.isString suffix then ", suffix: ${suffix}" else "");
        wantedBy = [ "timers.target" ];

        timerConfig = {
          OnCalendar = cfg.onCalendar;
          Persistent = true;
          Unit = "${name}.service";
        };
      };
    };
in
{
  options.services.refresher = mkOption {
    type = types.attrsOf (types.submodule {
      options.enable = mkOption {
        type = types.bool;
        default = true;
        description = lib.mdDoc ''
          Whether to enable this refresher's instance and create its environment.
        '';
      };

      options.repo = mkOption {
        type = types.str;
        example = "git@github.com:NixOS/nixpkgs";
        description = lib.mdDoc ''
          URL to the repo containing the flake. Must have write priviliges.
        '';
      };

      options.onCalendar = mkOption {
        type = types.str;
        default = "06:00:00";
        example = "hourly";
        description = lib.mdDoc ''
          Systemd timer's OnCalendar value.
        '';
      };

      options.inputs = mkOption {
        type = types.listOf types.str;
        example = [ "nixpkgs" ];
        default = [ ];
        description = lib.mdDoc ''
          Inputs to update. Updates all by default.
        '';
      };

      options.identity = mkOption {
        type = types.path;
        example = "/etc/ssh/id_ed25519";
        description = lib.mdDoc ''
          Path to an identity file to use. Should be root-readable.
        '';
      };

      options.extraSSHConf = mkOption {
        type = types.lines;
        default = "";
        description = lib.mkDoc ''
          Appended to SSH configuration used by the server's git command.
          Use service's identity option if you want to specify id to be used.
        '';
      };

      options.authorName = mkOption {
        type = types.str;
        default = "refresher";
        description = lib.mkDoc ''
          Who authored the commit.
        '';
      };

      options.authorEmail = mkOption {
        type = types.str;
        default = "refresher@example.com";
        description = lib.mkDoc ''
          Email of the commit's author.
        '';
      };

      options.staging = mkOption {
        type = types.bool;
        default = false;
        description = lib.mkDoc ''
          Whether operate on a separate staging branch.
        '';
      };
    });
    default = { };
  };

  config.systemd = lib.mkMerge (lib.mapAttrsToList mkServices config.services.refresher);
}
