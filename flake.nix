{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    musnix.url = "github:musnix/musnix";
    hydra.url = "github:NixOS/hydra";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    keys = {
      url = "./ssh/";
      flake = false;
    };
  };

  outputs = inputs: with inputs; rec {
    lib = import ./lib.nix nixpkgs.lib;

    desktopMods = [
      (import ./modules/doas.nix [ "hunter" ])
      ./modules/default.nix
      ./modules/i3.nix
      ./modules/nvidia.nix
      ./modules/pipewire.nix
    ];

    nixosConfigurations = {

      distortion = lib.mkHost inputs "x86_64-linux" "distortion" ([
        musnix.nixosModules.musnix
        { musnix.enable = true; }
        {
          nixpkgs.overlays = [
            (
              final: prev: { postgresql_11 = final.postgresql_12; }
            )
          ];
        }

        hydra.nixosModules.hydraTest
        ({ pkgs, ... }: {
          boot.isContainer = true;

          # Network configuration.
          networking.useDHCP = false;
          networking.firewall.allowedTCPPorts = [ 80 3000 ];
        })
      ] ++ desktopMods);

      shears = lib.mkHost inputs "x86_64-linux" "shears" ([
        (lib.mkKeys keys "hunter")
      ] ++ desktopMods);

      blueberry = lib.mkHost inputs "x86_64-linux" "blueberry" [
        ./modules/nginx.nix
        blog.nixosModules.default
        (lib.mkKeys keys "hunter")
      ];

    };

    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [
            (
              final: prev: { postgresql_11 = final.postgresql_12; }
            )
          ];
        }

        hydra.nixosModules.hydraTest
        ({ pkgs, ... }: {
          boot.isContainer = true;

          # Network configuration.
          networking.useDHCP = false;
          networking.firewall.allowedTCPPorts = [ 80 3000 ];
        })
      ];
    };

  };
}
