{ inputs, lib, ... }:
{
  imports =
    (builtins.filter (x: !(lib.hasSuffix "default.nix" x))
      (inputs.self.lib.ls "${inputs.self}/modules/default"))
    ++ (inputs.self.lib.ls "${inputs.self}/modules/share")
    ++ [
      { nixpkgs.overlays = inputs.nixpkgs.lib.attrValues inputs.self.overlays; }
      inputs.impermanence.nixosModules.impermanence
      inputs.agenix.nixosModules.default
      inputs.stylix.nixosModules.stylix
    ];

  # NOTE: needed for nixd. the issue: https://github.com/nix-community/nixd/issues/357
  nixpkgs.config.permittedInsecurePackages = [
    "nix-2.16.2"
  ];
}
