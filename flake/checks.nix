{ lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption mkOption types;
  opts = config.checks;
in {
  options = {
    checks = {
      enable = mkEnableOption "checks";
      nixpkgs = mkOption {
        type = types.raw;
        default = null;
      };
      eval = {
        specialArgs = mkOption {
          type = types.attrsOf types.raw;
          default = null;
        };
        modules = mkOption {
          type = types.listOf types.raw;
          default = null;
        };
      };
      check = {
        specialArgs = mkOption {
          type = types.attrsOf types.raw;
          default = null;
        };
        modules = mkOption {
          type = types.listOf types.raw;
          default = null;
        };
      };
    };
  };

  config = mkIf opts.enable {
    perSystem = { pkgs, system, ... }: {
      checks = let

        allmods = opts.nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = opts.eval.specialArgs;
          modules = opts.eval.modules;
        };

        checksConf = allmods.config.personal.checks;

        mkCheck = name: conf:
          opts.nixpkgs.lib.nixos.runTest {
            name = name;

            node.specialArgs = opts.check.specialArgs;

            nodes.machine = { imports = opts.check.modules ++ conf.modules; };

            hostPkgs = pkgs;

            testScript = ''
              start_all()
              ${conf.script}
            '';
          };

      in lib.mapAttrs mkCheck checksConf;
    };
  };
}
