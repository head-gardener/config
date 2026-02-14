{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hunter = inputs.self.homeModules.default;
    extraSpecialArgs = {
      inherit inputs;
      inherit (pkgs.stdenv.hostPlatform) system;
    };
  };
}
