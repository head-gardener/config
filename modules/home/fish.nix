{ lib, pkgs, ... }:
let
  nixplug = src: {
    name = "${src.pname}-${src.version}";
    src = src.src;
  };
in
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -al";
      mux = "tmuxinator";
      ip = "ip -c";
    };
    shellAbbrs = {
      sys = "systemctl";
      sus = "systemctl --user";
      n = "nix";
    };
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
    plugins = map nixplug (with pkgs.fishPlugins; [
      abbreviation-tips
      autopair
      done
      forgit-no-grc
      fzf-fish
      gitnow
      puffer
      spark
    ]);
  };
}
