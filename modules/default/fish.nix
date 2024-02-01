{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs.fishPlugins; [
    abbreviation-tips
    autopair
    done
    forgit-no-grc
    fzf-fish
    gitnow
    puffer
    spark
  ];

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
  };
}
