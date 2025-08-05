{ lib, config, ... }:
let
  mkUnitControlRule = { name, value }: ''
    // mkUnitcontrolRule ${name} for ${
      builtins.toString value.users + " " + builtins.toString value.groups
    }

    polkit.addRule(function(action, subject) {
      if (
        action.id == "org.freedesktop.systemd1.manage-units"
        && action.lookup("unit") == "${name}"
        ${
          lib.optionalString
          ((lib.length value.users) != 0 || (lib.length value.groups) != 0)
          "&& ( ${
            lib.strings.concatStringsSep " || "
            ((lib.map (u: ''subject.user == "${u}"'') value.users)
              ++ (lib.map (g: ''subject.isInGroup("${g}")'') value.groups))
          } ) "
        }
        ${
          lib.optionalString ((lib.length value.actions) != 0) "&& ( ${
            lib.strings.concatMapStringsSep " || "
            (a: ''action.lookup("verb") == "${a}"'') value.actions
          } ) "
        }
      ) {
        return polkit.Result.YES;
      }
    })
  '';

  cfg = config.personal.polkit;
in {
  options.personal.polkit = {
    allowUnitControl = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          users = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = lib.mkDoc ''
              User names
            '';
          };
          groups = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
            description = lib.mkDoc ''
              Group names
            '';
          };
          actions = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "start" "stop" "restart" ];
            description = lib.mkDoc ''
              Actions to allow
            '';
          };
        };
      });
      default = { };
      description = ''
        Allow users to start/stop a unit. Leaving groups and users empty (default)
        allows control for all users/groups.
      '';
    };
  };

  config.security.polkit.extraConfig = ''
    ${lib.strings.concatMapStrings mkUnitControlRule
    (lib.attrsToList cfg.allowUnitControl)}
  '';
}
