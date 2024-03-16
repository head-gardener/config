{ pkgs, inputs, ... }:
{
  services.xserver.displayManager.lightdm = {
    enable = true;
    background = "${inputs.self}/dots/static/11.png";
  };
}
