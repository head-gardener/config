{ pkgs, inputs, ... }:
{
  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile "${inputs.self}/dots/kitty/kitty.conf";
    shellIntegration.enableFishIntegration = true;
  };
}
