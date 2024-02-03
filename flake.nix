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

    lib = import ./lib.nix inputs nixpkgs.lib;

    overlays = self.lib.mkOverlays inputs ./overlays // {
      packages = final: prev: import ./pkgs final;
    };

    checks = {
      inherit (self.hydraJobs) x86_64-linux;
    };

    hydraJobs.x86_64-linux =
      { inherit (self.packages) x86_64-linux; }.x86_64-linux // {
        mkHost = nixpkgs.lib.nixos.runTest {
          name = "mkHost-test";

          nodes.machine = {
            imports = self.lib.mkHostModules "test";
          };

          hostPkgs = nixpkgs.legacyPackages.x86_64-linux;

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
            system = "x86_64-linux";
          };
          nodes.machine = {
            imports = [ ] ++
              self.lib.mkHostModules "test" ++
              self.lib.mkDesktopModules "test";
            home-manager.users.hunter.manual.manpages.enable = false;
          };

          hostPkgs = nixpkgs.legacyPackages.x86_64-linux;

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
    # takes too long to evaluate
    #// {
    #  x86_64-linux = nixpkgs.lib.mapAttrs
    #    (n: v: v.config.system.build.toplevel)
    #    self.nixosConfigurations;
    #};

    nixosModules =
      let
        share = self.lib.genAttrsFromDir ./modules/share import;
      in {
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
          ./modules/doas.nix
          ./modules/lightdm.nix
          ./modules/pipewire.nix
          ./modules/xserver.nix
          ./modules/picom.nix
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
        ./modules/i3.nix
        ({ pkgs, ... }: { environment.binsh = "${pkgs.dash}/bin/dash"; })
      ];

      shears = self.lib.mkDesktop "x86_64-linux" "shears" [
        (self.lib.mkKeys self "hunter")
        ./modules/cache.nix
        ./modules/xmonad.nix
        ./modules/upower.nix
        { boot.kernel.sysctl = { "vm.swappiness" = 20; }; }
      ];

      blueberry = self.lib.mkHost "x86_64-linux" "blueberry" [
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
        { boot.isContainer = true; }
      ];
      specialArgs = { inherit inputs; };
    };

    nixosConfigurations.xmonad = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./modules/vm
        ./modules/vm/graphical.nix
        ./modules/xserver.nix
        ./modules/xmonad.nix
        "${nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
        (self.lib.mkKeys self "hunter")
        ./modules/default/openssh.nix
        ./modules/default/tmux.nix
        (self.lib.addPkgs (pkgs: with pkgs; [ dmenu self ]))
      ];
      specialArgs = { inherit inputs; };
    };

  } // (flake-utils.lib.eachDefaultSystem (system: {
    packages = import ./pkgs (self.lib.nixpkgsFor system);
  }));
}
