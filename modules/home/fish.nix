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
      tp = "pushd $(mktemp -d)";
      mux-tp = "tmux new-session -d -c $(mktemp -d) -s tmp";
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

      function nom-rebuild-d --wraps nixos-rebuild --description "nom-wrapped doas nixos-rebuild"
        doas w > /dev/null
        doas nixos-rebuild $argv --log-format internal-json -v 2>| nom --json
      end

      function nom-rebuild --wraps nixos-rebuild --description "nom-wrapped nixos-rebuild"
        nixos-rebuild $argv --log-format internal-json -v 2>| nom --json
      end

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
