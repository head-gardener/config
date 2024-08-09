{ inputs, ... }:
{
  system = {
    stateVersion = "24.05";
    copySystemConfiguration = false;
  };

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
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "root" "hunter" ];
      allowed-uris = [ "https://github.com/NixOS/nixpkgs/archive/" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
    };
  };
}
