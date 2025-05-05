{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{

  options.personal.facts = mkOption {
    type = types.raw;
    default = { };
    description = lib.mdDoc ''
      Facts about a host
    '';
  };

}
