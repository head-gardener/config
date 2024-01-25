{
  inputs = {
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    musnix.url = "github:musnix/musnix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: with inputs; rec {

    lib = import ./lib.nix nixpkgs.lib;

    overlays =
      lib.importAll ./overlays // {
        packages = final: prev: import ./pkgs final;
      };

    packages = lib.forAllSystems
      (system: import ./pkgs nixpkgs.legacyPackages.${system});

    nixosModules = rec {
      home = { inputs, ... }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.hunter = import ./modules/home.nix;
          extraSpecialArgs = { inherit inputs; };
        };
      };

      default.imports = [
        ./modules/default.nix
        ./modules/nix.nix
        ./modules/openssh.nix
        ./modules/tools.nix
        {
          nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays;
        }
      ];

      desktop.imports = [
        (import ./modules/doas.nix [ "hunter" ])
        ./modules/i3.nix
        ./modules/nvidia.nix
        ./modules/pipewire.nix
      ];
    };

    nixosConfigurations = {

      distortion = lib.mkDesktop inputs "x86_64-linux" "distortion" [
        musnix.nixosModules.musnix
        { musnix.enable = true; }
        ./modules/cache.nix
      ];

      shears = lib.mkDesktop inputs "x86_64-linux" "shears" [
        (lib.mkKeys self "hunter")
        ./modules/cache.nix
      ];

      blueberry = lib.mkHost inputs "x86_64-linux" "blueberry" [
        ./modules/nginx.nix
        ./modules/nas.nix
        blog.nixosModules.blog
        (lib.mkKeys self "hunter")
      ];

    };

    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
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
