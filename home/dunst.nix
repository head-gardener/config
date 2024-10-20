{ inputs, ... }:
{
  services.dunst = {
    enable = true;
    configFile = "${inputs.self}/dots/dunst/dunstrc";
  };
}
