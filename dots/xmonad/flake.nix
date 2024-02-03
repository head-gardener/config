{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
  };
  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.haskell-flake.flakeModule ];

      perSystem = { self', pkgs, config, ... }: {
        haskellProjects.default = {
          devShell = {
            tools = hp: {
              inherit (pkgs) hpack;
              inherit (hp);
            };

            hlsCheck.enable = true;
          };
        };

        packages.default = self'.packages.my-xmonad;
      };
    };
}
