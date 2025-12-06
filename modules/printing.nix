{ pkgs, inputs, ... }:

{
  nixpkgs.allowUnfreeByName = [
    "hplip"
  ];

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      canon-capt
      foo2zjs
      hplipWithPlugin
      inputs.capt.packages.${pkgs.stdenv.hostPlatform.system}.capt-bin
      inputs.capt.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
