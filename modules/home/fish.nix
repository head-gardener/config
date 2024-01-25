{ lib, pkgs, ... }:
{
  programs.tmux.shell = "${pkgs.fish}/bin/fish";

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
    plugins =
      let
        ghplug = url: {
          name = lib.last (lib.splitString "/" url);
          src = fetchGit { url = url; };
        };
      in
      builtins.map ghplug [
      ];
  };
}
