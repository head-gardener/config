{ pkgs, ... }:
{
  environment.systemPackages = with pkgs.fishPlugins; [ nix-completions ];

  environment.pathsToLink = [ "/share/fish" ];
}
