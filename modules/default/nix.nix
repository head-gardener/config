{
  system = {
    stateVersion = "23.11";
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
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = {
          owner = "NixOS";
          repo = "nixpkgs";
          ref = "nixos-23.11";
          type = "github";
        };
      };
      config = {
        from = {
          id = "config";
          type = "indirect";
        };
        to = {
          owner = "head-gardener";
          repo = "config";
          type = "github";
        };
      };
    };

    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "root" "hunter" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    optimise = {
      automatic = true;
    };
  };
}
