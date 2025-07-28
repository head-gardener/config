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
      inputs.capt.packages.${pkgs.system}.capt-bin
      inputs.capt.packages.${pkgs.system}.default
    ];
  };
}
