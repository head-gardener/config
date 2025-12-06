{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.hunter = import "${inputs.self}/home";
    extraSpecialArgs = {
      inherit inputs;
      inherit (pkgs.stdenv.hostPlatform) system;
    };
  };
}
