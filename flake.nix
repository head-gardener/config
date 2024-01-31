{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    musnix.url = "github:musnix/musnix";
    nixd.url = "github:nix-community/nixd";
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

    hydraJobs = {
      inherit (self.packages) x86_64-linux;
    };
    # takes too long to evaluate
    #// {
    #  x86_64-linux = nixpkgs.lib.mapAttrs
    #    (n: v: v.config.system.build.toplevel)
    #    self.nixosConfigurations;
    #};

    nixosModules = rec {
      home = { inputs, ... }: {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.hunter = import ./modules/home.nix;
          extraSpecialArgs = {
            inherit inputs;
            system = "x86_64-linux";
          };
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
        ./modules/doas.nix
        ./modules/i3.nix
        ./modules/lightdm.nix
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
        (self.lib.mkKeys self "hunter")
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

    nixosConfigurations.container = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules/vm
        (self.lib.mkKeys self "hunter")
        ./modules/default/openssh.nix
        ./modules/default/tmux.nix
      ];
      specialArgs = { inherit inputs; };
    };

    nixosConfigurations.xmonad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules/vm
        ./modules/vm/graphical.nix
        ./modules/xmonad.nix
        (self.lib.mkKeys self "hunter")
        ./modules/default/openssh.nix
        ./modules/default/tmux.nix
        (self.lib.addPkgs (pkgs: with pkgs; [ dmenu self ]))
      ];
      specialArgs = { inherit inputs; };
    };

  } // (flake-utils.lib.eachDefaultSystem (system: {
    packages = import ./pkgs nixpkgs.legacyPackages.${system};
  }));
}
