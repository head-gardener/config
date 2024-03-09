{ inputs, pkgs, config, ... }:

{
  stylix = {
    targets = {
      emacs.enable = true;
      feh.enable = true;
      firefox.enable = true;
      fish.enable = true;
      fzf.enable = true;
      gtk.enable = true;
      kitty.enable = true;
      kitty.variant256Colors = true;
      # nushell.enable = true;
      tmux.enable = true;
    };
  };
}
