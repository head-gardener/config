{ lib, pkgs, ... }:
{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -al";
      mux = "tmuxinator";
    };
    shellAbbrs = {
      sys = "systemctl";
      sus = "systemctl --user";
      n = "nix";
    };
    interactiveShellInit = ''
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
    '';
    plugins =
      let
        nixplug = src: {
          name = "${src.pname}-${src.version}";
          src = src.src;
        };
      in
      builtins.map nixplug (with pkgs.fishPlugins; [
        autopair
        done
        fzf-fish
        puffer
      ]);
  };
}
