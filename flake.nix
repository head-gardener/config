{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    xmonad.inputs.nixpkgs.follows = "nixpkgs";

    notes.url = "github:head-gardener/notes";
    notes.flake = false;

    agenix.url = "github:ryantm/agenix";
    auspex.url = "github:head-gardener/auspex";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    dmenu-conf.url = "github:head-gardener/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    impermanence.url = "github:nix-community/impermanence";
    musnix.url = "github:musnix/musnix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixd.url = "github:nix-community/nixd";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    stylix.url = "github:danth/stylix/release-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    xmonad.url = "github:head-gardener/xmonad";
    # xmonad.url = "/home/hunter/xmonad/";
  };

  outputs = inputs: with inputs; flake-parts.lib.mkFlake { inherit inputs; } {
    flake = {
      lib = import ./lib.nix inputs nixpkgs.lib;

      overlays = self.lib.mkOverlays inputs ./overlays // {
        packages = final: _: import ./pkgs final;
      };

      nixosModules = self.lib.genAttrsFromDir ./modules/share lib.id;

      nixosConfigurations = {
        distortion = self.lib.mkDesktop "x86_64-linux" "distortion" [ ];
        shears = self.lib.mkDesktop "x86_64-linux" "shears" [ ];
        apple = self.lib.mkHost "x86_64-linux" "apple" [ ];
        blueberry = self.lib.mkHost "x86_64-linux" "blueberry" [ ];
        cherry = self.lib.mkHost "x86_64-linux" "cherry" [ ];
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
            ./modules/default/tmux.nix
            ./modules/default/tools.nix
          ];
        };

        test = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./modules/vm/qemu.nix
          ];
        };
      };
    };

    systems = [ "x86_64-linux" ];

    perSystem = { pkgs, system, self', ... }: {
      _module.args.pkgs = self.lib.nixpkgsFor system;

      packages = import ./pkgs pkgs;

      checks = self'.packages // {
        mkHost = nixpkgs.lib.nixos.runTest {
          name = "mkHost-test";

          node.specialArgs = {
            inherit inputs;
          };

          nodes.machine = {
            imports = self.lib.mkHostModules "test";
          };

          hostPkgs = pkgs;

          testScript = ''
            start_all()
            machine.wait_for_unit("multi-user.target")
            machine.succeed("tmux -V")
            machine.succeed("nix doctor")
            machine.succeed("ss -lt | grep ssh")
            machine.succeed("su hunter -c 'whoami'")
          '';
        };

        mkDesktop = nixpkgs.lib.nixos.runTest {
          name = "mkDesktop-test";

          node.specialArgs = {
            inherit inputs;
          };

          nodes.machine = {
            imports = [ ] ++
              self.lib.mkHostModules "test" ++
              self.lib.mkDesktopModules "test";
            home-manager.users.hunter.manual.manpages.enable = false;
          };

          hostPkgs = pkgs;

          testScript = ''
            start_all()
            machine.wait_for_unit("multi-user.target")
            machine.succeed("tmux -V")
            machine.succeed("nix doctor")
            machine.succeed("ss -lt | grep ssh")
            machine.succeed("su hunter -c 'whoami'")
            machine.wait_for_unit("display-manager.service")
          '';
        };
      };

      legacyPackages = pkgs;
    };
  };
}
