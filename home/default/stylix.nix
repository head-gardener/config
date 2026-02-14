{ inputs, pkgs, config, ... }:

{
  stylix = {
    targets = {
      emacs.enable = true;
      feh.enable = true;
      firefox.enable = true;
      fish.enable = false; # write(1, "\33Ptmux;\33\33]4;0;rgb:12/12/12\33\33\\033"..., 33 freeze
      fzf.enable = true;
      gtk.enable = true;
      kitty.enable = true;
      kitty.variant256Colors = true;
      # nushell.enable = true;
      tmux.enable = true;
    };
  };
}
