{ pkgs, inputs, ... }:
{
  programs.kitty = {
    enable = true;
    font = {
      package = pkgs.lilex;
      name = "Lilex Nerd Font Medium";
      size = 10.0;
    };
    extraConfig = builtins.readFile "${inputs.self}/dots/kitty/kitty.conf";
    shellIntegration.enableFishIntegration = true;
  };
}
