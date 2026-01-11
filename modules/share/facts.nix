{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.personal.facts;
  exists = builtins.pathExists cfg.factsFile;

  perlEnv = pkgs.perl;
  pkg = pkgs.writeShellApplication {
    name = "facts";
    runtimeInputs = with pkgs; [
      btrfs-progs
      e2fsprogs
      iproute2
      systemd
      util-linux
    ];
    runtimeEnv = {
      FACTS_SWAPFILES = if config.personal.hibernate.enable then config.personal.hibernate.file else "";
    };
    text = ''
      "${lib.getExe' perlEnv "perl"}" "${inputs.self}/scripts/gather-facts.pl" \
        | ${lib.getExe pkgs.jq} -S .
    '';
  };
in
{
  options.personal.facts = {
    enable = lib.mkEnableOption "facts";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkg;
      description = "Wrapped gather-facts.pl script.";
    };

    factsFile = lib.mkOption {
      type = lib.types.path;
      default = "${inputs.self}/hosts/${config.networking.hostName}/facts.json";
      description = "Path to read-only facts file.";
    };

    facts = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      readOnly = true;
      description = "Non-null if facts are available.";
    };
  };

  config = lib.mkMerge [
    {
      personal.facts.facts = lib.mkMerge [
        (lib.mkIf (exists && cfg.enable) (builtins.fromJSON (builtins.readFile cfg.factsFile)))
        (lib.mkIf (!(exists && cfg.enable)) (
          lib.warn ''
            Facts file ${cfg.factsFile} doesn't exit or isn't enabled!
          '' null
        ))
      ];
    }
    (lib.mkIf (cfg.enable && exists) {
      systemd.services.check-facts = {
        description = "Check facts for consistency";
        after = [ "multi-user.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [
          pkgs.diffutils
        ];

        script = ''
          set +e
          (
            set -eo pipefail
            test -f "${cfg.factsFile}"
            diff "${cfg.factsFile}" <("${lib.getExe cfg.package}")
          )
          rc="$?"
          if [ "$rc" -ne 0 ]; then
            echo "Warning: facts changed!"
            echo -n 'Tried "diff ${cfg.factsFile} <(${lib.getExe cfg.package})"'
            exit 1
          else
            echo "Facts are up-to-date."
            exit 0
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          Restart = "no";
          SuccessExitStatus = "0 1";
          RemainAfterExit = true;
        };
      };
    })
  ];
}
