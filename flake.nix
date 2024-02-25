{
  inputs = {
    agenix.inputs.nixpkgs.follows = "nixpkgs";
    blog.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hydra.inputs.nixpkgs.follows = "nixpkgs";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    nixd.inputs.nixpkgs.follows = "nixpkgs";
    xmonad.inputs.nixpkgs.follows = "nixpkgs";

    notes.url = "github:head-gardener/notes";
    notes.flake = false;

    agenix.url = "github:ryantm/agenix";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
    dmenu-conf.url = "github:head-gardener/nixpkgs/master";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    hydra.url = "github:NixOS/hydra";
    musnix.url = "github:musnix/musnix";
    neovim-nightly.url = "github:nix-community/neovim-nightly-overlay";
    nixd.url = "github:nix-community/nixd";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
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

      nixosModules =
        let
          share = self.lib.genAttrsFromDir ./modules/share import;
        in
        {
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

          default.imports =
            (self.lib.ls ./modules/default) ++ [
              { nixpkgs.overlays = nixpkgs.lib.attrValues self.overlays; }
            ] ++ nixpkgs.lib.attrValues share;

          desktop.imports = [
            { nixpkgs.overlays = [ neovim-nightly.overlay ]; }
            ./modules/doas.nix
            ./modules/lightdm.nix
            ./modules/picom.nix
            ./modules/pipewire.nix
            ./modules/xserver.nix
          ];
        } // share;

      nixosConfigurations = {
        distortion = self.lib.mkDesktop "x86_64-linux" "distortion" [
          musnix.nixosModules.musnix
          {
            musnix.enable = true;
            users.users.hunter.extraGroups = [ "audio" ];
          }
          ./modules/cache.nix
          ./modules/nvidia.nix
          ./modules/xmonad.nix
          ./modules/github.nix
          ({ pkgs, ... }: { environment.binsh = "${pkgs.dash}/bin/dash"; })
        ];

        shears = self.lib.mkDesktop "x86_64-linux" "shears" [
          (self.lib.mkKeys self "hunter")
          xmonad.nixosModules.powerwatch
          ./modules/cache.nix
          ./modules/github.nix
          ./modules/xmonad.nix
          ./modules/upower.nix
          { services.easyeffects.enable = true; }
          { boot.kernel.sysctl = { "vm.swappiness" = 20; }; }
        ];

        apple = self.lib.mkHost "x86_64-linux" "apple" [
          (self.lib.mkKeys self "hunter")
          ./modules/cache.nix
        ];

        blueberry = self.lib.mkHost "x86_64-linux" "blueberry" [
          ./modules/nginx.nix
          ./modules/nas.nix
          ./modules/hydra.nix
          blog.nixosModules.blog
          (self.lib.mkKeys self "hunter")
          agenix.nixosModules.default
          ./modules/refresher-staging.nix
          ./modules/refresher-config.nix
        ];
      };
    };

    systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];

    perSystem = { pkgs, system, self', ... }: {
      # TODO: doesn't work!
      # _module.args.pkgs = import inputs.nixpkgs {
      #   inherit system;
      #   overlays = [
      #     self.overlays.packages
      #   ];
      # };
      # packages = import ./pkgs pkgs;

      packages = import ./pkgs (self.lib.nixpkgsFor system);

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
    };
  };
}
