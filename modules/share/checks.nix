{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{

  options.personal.checks = mkOption {
    type = types.raw;
    default = { };
    description = lib.mdDoc ''
      Checks to perform
    '';
  };

}
