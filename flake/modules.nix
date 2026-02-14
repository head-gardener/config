{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;

  opts = config.modules;

  build_modules =
    let
      collect =
        f: path:
        lib.mapAttrsToList (
          name: type:
          if type == "directory" then
            let
              children = f (lib.path.append path name);
              prefixed = map (x: x // { name = name + "-" + x.name; }) children;
            in
            [
              (if (builtins.elem name opts.withPrefix) then prefixed else children)
              # for importing everything from a directory
              # notice that directories can't nest!
              # it's kinda complex to implement for no real benefit
              {
                name = name;
                value =
                  let
                    mkMod =
                      { exclude }:
                      {
                        imports = lib.map (x: x.value) (lib.filter (x: !builtins.elem x.name exclude) children);
                      };
                  in
                  (mkMod {
                    exclude = [ ];
                  })
                  // {
                    options.passthru = lib.mkOption { type = lib.types.raw; };
                    config.passthru.override = mkMod;
                  };
              }
            ]
          else
            {
              name = lib.head (lib.splitString ".nix" name);
              value = lib.path.append path name;
            }
        ) (builtins.readDir path);

      flatten = set: lib.listToAttrs (lib.lists.flatten set);
    in
    path: flatten (lib.fix collect path);
in
{
  options = {
    modules = {
      nixosRoot = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      withPrefix = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      homeRoot = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
    };
  };

  config = {
    flake.nixosModules = mkIf (opts.nixosRoot != null) (build_modules opts.nixosRoot);

    flake.homeModules = mkIf (opts.nixosRoot != null) (build_modules opts.homeRoot);
  };
}
