{ lib, ... }:
{
  options.personal.checks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.deferredModule;
          default = [];
        };
        script = lib.mkOption {
          type = lib.types.lines;
          default = ''
            machine.wait_for_unit("multi-user.target")
          '';
        };
      };
    });
    default = { };
    description = lib.mdDoc ''
      Checks to perform
    '';
  };
}
