{ inputs, ... }: {
  nix = {
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
      # needed for hydra. TODO investigate
      allowed-uris = [
        "https://"
        "github:"
      ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };
}
