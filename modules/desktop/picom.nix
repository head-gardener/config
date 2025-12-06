{ lib, inputs, ... }:
{
  services.picom = {
    enable = true;
    settings = lib.importJSON "${inputs.self}/dots/picom.json";
  };
}
