{ inputs, pkgs, config, lib, ... }: {
  options = {
    personal.gc.maxAge = lib.mkOption { type = lib.types.int; default = 14; };
  };

  config = {
    nix = {
      package = pkgs.lix;

      registry = {
        unstable = {
          from = {
            id = "unstable";
            type = "indirect";
          };
          to = {
            owner = "NixOS";
            repo = "nixpkgs";
            ref = "nixos-unstable";
            type = "github";
          };
        };
        nixpkgs.flake = inputs.nixpkgs;
        agenix.flake = inputs.agenix;
        s.flake = inputs.self;
      };

      settings = {
        flake-registry = null;

        # needed for hydra. TODO investigate
        allowed-uris = [
          "https://"
          "github:"
        ];
      };

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than \"${toString config.personal.gc.maxAge}d\"";
      };
    };
  };
}
