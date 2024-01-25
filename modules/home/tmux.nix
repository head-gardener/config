{

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    prefix = "C-a";
    mouse = true;
    extraConfig = ''
      set -g status-style bg=default
      set -s escape-time 0
      set -g status-keys emacs
      set -g mode-keys vi
    '';
    newSession = true;
  };

}
