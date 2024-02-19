{ lib, pkgs, inputs, ... }:
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
      ip = "ip -c";
      la = "ls -al";
      ll = "ls -l";
      mux = "tmuxinator";
    };
    shellAbbrs = {
      loc = "XDG_CONFIG_HOME=~/config/dots";
      n = "nix";
      nbl = "nix build .";
      nbn = "nix build nixpkgs";
      nrn = "nix run nixpkgs#";
      sus = "systemctl --user";
      sys = "systemctl";
    };
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      setenv LS_COLORS "${builtins.readFile pkgs.ls_colors}"
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
