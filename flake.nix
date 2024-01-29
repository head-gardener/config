{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    musnix.url = "github:musnix/musnix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    sops-nix.url = "github:Mic92/sops-nix";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: with inputs; {

    lib = import ./lib.nix nixpkgs.lib;

    overlays =
      self.lib.mkOverlays inputs ./overlays // {
        packages = final: prev: import ./pkgs final;
      };

    hydraJobs = { inherit (self.packages) x86_64-linux; };

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

      default.imports =
        (self.lib.ls ./modules/default) ++ [
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
      distortion = self.lib.mkDesktop inputs "x86_64-linux" "distortion" [
        musnix.nixosModules.musnix
        {
          musnix.enable = true;
          users.users.hunter.extraGroups = [ "audio" ];
        }
        ./modules/cache.nix
        ./modules/nvidia.nix
        ({ pkgs, ... }: { environment.binsh = "${pkgs.dash}/bin/dash"; })
      ];

      shears = self.lib.mkDesktop inputs "x86_64-linux" "shears" [
        (lib.mkKeys self "hunter")
        ./modules/cache.nix
      ];

      blueberry = self.lib.mkHost inputs "x86_64-linux" "blueberry" [
        ./modules/nginx.nix
        ./modules/nas.nix
        ./modules/hydra.nix
        blog.nixosModules.blog
        (self.lib.mkKeys self "hunter")
        agenix.nixosModules.default
      ];
    };

    nixosConfigurations.container = nixpkgs.lib.nixosSystem
      {
        system = "x86_64-linux";
        modules = [
          (self.lib.mkKeys self "hunter")
          ./modules/default/openssh.nix
          ./modules/default/tmux.nix
          ({ pkgs, ... }: {
            users.users.hunter = {
              isNormalUser = true;
              password = "hunter";
            };
            boot.isContainer = true;
            system.stateVersion = "23.11";
            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [ 80 3000 ];
          })
        ];
      };

  } // (flake-utils.lib.eachDefaultSystem (system: {
    packages = import ./pkgs nixpkgs.legacyPackages.${system};
  }));
}
