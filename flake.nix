{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    # blog.url = "/home/hunter/Blog/";
    blog.url = "github:head-gardener/blog";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    musnix.url = "github:musnix/musnix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    sops-nix.url = "github:Mic92/sops-nix";
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

    hydraJobs = { inherit (self) packages; };

    nixosModules = rec {
      home = { inputs, ... }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.hunter = import ./modules/home.nix;
          extraSpecialArgs = { inherit inputs; };
        };
      };

      sops = {
        imports = [ sops-nix.nixosModules.sops ];
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        sops.age.keyFile = "/var/lib/sops-nix/key.txt";
        sops.age.generateKey = true;

        sops.defaultSopsFile = ./secrets/cache.yaml;
        # sops.secrets."cache-priv.pem" = { };
        # sops.secrets."cache-pub.pem" = { };
        sops.secrets."key" = { };
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
        ./modules/pipewire.nix
      ];
    };

    nixosConfigurations = {
      distortion = lib.mkDesktop inputs "x86_64-linux" "distortion" [
        musnix.nixosModules.musnix
        { musnix.enable = true; }
        ./modules/cache.nix
        ./modules/nvidia.nix
      ];

      shears = lib.mkDesktop inputs "x86_64-linux" "shears" [
        (lib.mkKeys self "hunter")
        ./modules/cache.nix
      ];

      blueberry = lib.mkHost inputs "x86_64-linux" "blueberry" [
        ./modules/nginx.nix
        ./modules/nas.nix
        ./modules/hydra.nix
        blog.nixosModules.blog
        (lib.mkKeys self "hunter")
        agenix.nixosModules.default
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
