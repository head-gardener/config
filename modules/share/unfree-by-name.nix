{ config, lib, pkgs, ... }:

with lib;

{

  options.nixpkgs.allowUnfreeByName = mkOption {
    type = types.listOf types.str;
    default = [ ];
    example = [
      "steam"
      "hplip"
    ];
    description = lib.mdDoc ''
      List of package names to allow. Should not be used with `allowUnfreePredicate`.
    '';
  };

  config = mkIf (length config.nixpkgs.allowUnfreeByName != 0) {
    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem
        (getName pkg)
        config.nixpkgs.allowUnfreeByName;
  };

}
