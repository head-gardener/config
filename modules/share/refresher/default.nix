{ config, lib, pkgs, ... }:

with lib;

let

  githubHK = ''
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
  '';

  cfg = config.services.refresher;

  updateCmd = "${lib.getExe pkgs.nix} flake lock --commit-lock-file ${lib.concatMapStrings (x: " --update-input " + x) cfg.inputs}";


  sshCmd = "${lib.getExe pkgs.openssh} -i ${cfg.identity} -F ${pkgs.writeText "ssh_config" sshConfig}";

  sshConfig = ''
    StrictHostKeyChecking=accept-new
    UserKnownHostsFile=${pkgs.writeText "known_hosts" githubHK}
    ${cfg.extraSSHConf}
  '';

  name = "refresher" + (if lib.isString cfg.suffix then "-" + cfg.suffix else "");

in
{

  options.services.refresher = {
    enable = mkEnableOption "refresher";

    repo = mkOption {
      type = types.str;
      example = "git@github.com:NixOS/nixpkgs";
      description = lib.mdDoc ''
        URL to the repo containing the flake. Must have write priviliges.
      '';
    };

    onCalendar = mkOption {
      type = types.str;
      default = "06:00:00";
      example = "hourly";
      description = lib.mdDoc ''
        Systemd timer's OnCalendar value.
      '';
    };

    suffix = mkOption {
      type = types.str;
      default = null;
      example = "nixpkgs";
      description = lib.mdDoc ''
        Suffix to be added to services's and user's name, paths as such: "nixpkgs" -> "refresher-nixpkgs"
      '';
    };

    inputs = mkOption {
      type = types.listOf types.str;
      example = [ "nixpkgs" ];
      description = lib.mdDoc ''
        Inputs to update.
      '';
    };

    identity = mkOption {
      type = types.path;
      example = "/etc/ssh/id_ed25519";
      description = lib.mdDoc ''
        Path to an identity file to use. Should be an absolute pass readable to refresher user.
      '';
    };

    extraSSHConf = mkOption {
      type = types.lines;
      default = "";
      description = lib.mkDoc ''
        Appended to SSH configuration used by the server's git command.
        Use service's identity option if you want to specify id to be used.
      '';
    };

    authorName = mkOption {
      type = types.str;
      default = "refresher";
      description = lib.mkDoc ''
        Who authored the commit.
      '';
    };

    authorEmail = mkOption {
      type = types.str;
      default = "refresher@example.com";
      description = lib.mkDoc ''
        Email of the commit's author.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.users.${name} = {
      isSystemUser = true;
      group = name;
    };

    users.groups.${name} = { };

    systemd.services.${name} = {
      description = "Remote flake input updater"
        + (if lib.isString cfg.suffix then ", suffix: ${cfg.suffix}" else "");
      path = [ pkgs.git ];

      environment = {
        HOME = "/run/${name}";
        GIT_SSH_COMMAND = sshCmd;
        GIT_AUTHOR_NAME = cfg.authorName;
        GIT_COMMITTER_NAME = cfg.authorName;
        EMAIL = cfg.authorEmail;
      };

      script = ''
        ${lib.getExe pkgs.git} clone ${cfg.repo} . --depth 1 -v
        ${updateCmd}
        ${lib.getExe pkgs.git} push
      '';

      serviceConfig = {
        RuntimeDirectory = name;
        WorkingDirectory = "/run/${name}";
        Type = "oneshot";
        User = name;
      };
    };

    systemd.timers.${name} = {
      description = "Remote flake input updater"
        + (if lib.isString cfg.suffix then ", suffix: ${cfg.suffix}" else "");
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        Unit = name;
      };
    };
  };
}
