{ lib, config, ... }:
let
  cfg = config.personal.va;

  applyTemplate = n:
    t@{ owner ? "root", group ? "root", ... }:
    {
      inherit owner group;
      destination = "${cfg.secretsMountPoint}/${n}";
    } // t;

in
{
  options = {
    personal.va = {
      templates = lib.mkOption {
        default = { };
        type = with lib.types; lazyAttrsOf (lazyAttrsOf raw);
        apply = lib.mapAttrs applyTemplate;
      };
      secretsMountPoint = lib.mkOption {
        default = "/run/vault";
        type = lib.types.str;
      };
    };
  };
}
