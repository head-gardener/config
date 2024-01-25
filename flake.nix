{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    musnix.url = "github:musnix/musnix";
    hydra.url = "github:NixOS/hydra";
    blog.url = "github:head-gardener/blog";
    # blog.url = "/home/hunter/Blog/";
  };

  outputs = inputs: with inputs; rec {
    lib = import ./lib.nix nixpkgs.lib;

    defaultMods = [
      ./modules/openssh.nix
      ./modules/default.nix
    ];

    desktopMods = [
      (import ./modules/doas.nix [ "hunter" ])
      ./modules/i3.nix
      ./modules/nvidia.nix
      ./modules/pipewire.nix
    ];

    hydraMods = [
      {
        networking.firewall.allowedTCPPorts = [ 3000 ];
        services.hydra = {
          enable = true;
          hydraURL = "http://localhost:3000";
          notificationSender = "hydra@localhost";
          buildMachinesFiles = [ ];
          useSubstitutes = true;
        };
        services.postgresql.enable = true;
      }
    ];

    nixosConfigurations = {

      distortion = lib.mkHost inputs "x86_64-linux" "distortion" ([
        musnix.nixosModules.musnix
        { musnix.enable = true; }
      ] ++ defaultMods ++ desktopMods);

      shears = lib.mkHost inputs "x86_64-linux" "shears" ([
        (lib.mkKeys self "hunter")
      ] ++ defaultMods ++ desktopMods);

      blueberry = lib.mkHost inputs "x86_64-linux" "blueberry" [
        ./modules/nginx.nix
        blog.nixosModules.default
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
