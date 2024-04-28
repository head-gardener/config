{ pkgs, ... }:

{
  nixpkgs.allowUnfreeByName = [
    "hplip"
  ];

  services.printing = {
    enable = true;
    drivers = with pkgs; [ foo2zjs hplipWithPlugin ];
  };
}
