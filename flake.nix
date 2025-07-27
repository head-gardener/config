{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    alloy.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    nix-converter.inputs.nixpkgs.follows = "nixpkgs";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";
    notes.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    xmonad.inputs.nixpkgs.follows = "nixpkgs";

    alloy.url = "github:head-gardener/alloy";
    # alloy.url = "git+file:/home/hunter/Code/alloy";
    notes.url = "github:head-gardener/notes";
    # notes.url = "git+file:/home/hunter/notes/";
    xmonad.url = "github:head-gardener/xmonad";
    # xmonad.url = "git+file:/home/hunter/xmonad/";

    agenix.url = "github:ryantm/agenix";
    dmenu-conf.url = "github:head-gardener/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    hydra.url = "github:NixOS/hydra";
    impermanence.url = "github:nix-community/impermanence";
    musnix.url = "github:musnix/musnix";
    nix-converter.url = "github:theobori/nix-converter";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixd.url = "github:nix-community/nixd";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixvirt.url = "github:AshleyYakeley/NixVirt";
    stylix.url = "github:danth/stylix/release-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: with inputs; flake-parts.lib.mkFlake { inherit inputs; } {
    imports = [
      alloy.flakeModule
      ./flake/modules.nix
      ./flake/checks.nix
    ];

    modules = {
      nixosRoot = ./modules;
      homeRoot = ./home;
      withPrefix = [ "vm" ];
    };

    checks = {
      enable = true;
      inherit nixpkgs;
      eval = {
        specialArgs = { inherit inputs; };
        modules = nixpkgs.lib.attrValues self.nixosModules;
      };
      check = {
        specialArgs = { inherit inputs; };
        modules = self.lib.mkHostModules "test";
      };
    };

    flake = {
      lib = import ./lib.nix inputs nixpkgs.lib;

      overlays = self.lib.mkOverlays inputs ./overlays // {
        packages = final: _: import ./pkgs inputs final;
      };

      images = {
        installer = self.nixosConfigurations.installer.config.system.build.isoImage;
        digitalocean = self.nixosConfigurations.digitalocean.config.system.build.digitalOceanImage;
      };

      nixosModules = {
        defaultImports = {
          imports = [
            self.nixosModules.default
            self.nixosModules.share
            { nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays; }
            inputs.agenix.nixosModules.default
            inputs.impermanence.nixosModules.impermanence
            inputs.nixvirt.nixosModules.default
            inputs.stylix.nixosModules.stylix
            inputs.xmonad.nixosModules.myxmonad
          ];
        };
      };

      alloy.config = ./alloy_config.nix;
      alloy.extraSpecialArgs = { inherit self; };
      alloy.nixosConfigurations = {
        distortion = self.lib.mkDesktop "x86_64-linux" "distortion" [ ];
        shears = self.lib.mkDesktop "x86_64-linux" "shears" [ ];
        ambrosia = self.lib.mkDesktop "x86_64-linux" "ambrosia" [ ];

        apple = self.lib.mkHost "x86_64-linux" "apple" [ ];
        blueberry = self.lib.mkHost "x86_64-linux" "blueberry" [ ];
        cherry = self.lib.mkHost "x86_64-linux" "cherry" [ ];
        damson = self.lib.mkHost "x86_64-linux" "damson" [ ];
        elderberry = self.lib.mkHost "x86_64-linux" "elderberry" [
          "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
        ];

        digitalocean = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
          ];
        };

        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ({ pkgs, modulesPath, lib, ... }: {
              imports = [
                "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
              ];
              boot.kernelPackages = pkgs.linuxPackages_latest;
              boot.supportedFilesystems = lib.mkForce [ "btrfs" "reiserfs" "vfat" "f2fs" "xfs" "ntfs" "cifs" ];
            })
            (self.lib.mkKeys' self "nixos" "hunter")
            self.nixosModules.tmux
            self.nixosModules.tools
          ];
        };
      };
    };

    systems = [ "x86_64-linux" ];

    perSystem = { pkgs, system, ... }: {
      _module.args.pkgs = self.lib.nixpkgsFor system;

      packages = import ./pkgs inputs pkgs;

      devShells = {

        perl = pkgs.mkShell {
          name = "perl";
          packages = with pkgs; [
            gnumake
            (perl.withPackages (ps: [
              ps.CPANDistnameInfo
              ps.CPANMeta
              ps.LogLog4perl
              ps.ModuleBuild
              ps.locallib
            ]))
          ];

          shellHook = ''
            echo 'checking for cpan updates...'
            echo 'r CPAN::DistnameInfo Log::Log4perl Module::Build' \
              | cpan \
              | grep "^\w\+::" \
              || echo 'all good!'
            echo "PERL5LIB: $PERL5LIB"
          '';
        };

        k8s = pkgs.mkShell {
          name = "k8s";
          packages = with pkgs; [
            kind
            kubectl
            kubectl-example
            kubectl-explore
            kubectl-klock
            kubectl-ktop
            kubernetes-helm
            kustomize
            yq
          ];
        };

        ansible = pkgs.mkShell {
          name = "ansible";
          packages = with pkgs; [
            ansible
            ansible-lint
            (python3.withPackages (ps: [
              ps.docker
              ps.molecule
              ps.molecule-plugins
              ps.podman
              ps.python-vagrant
            ]))
          ];
        };

      };

      legacyPackages = pkgs;
    };
  };
}
