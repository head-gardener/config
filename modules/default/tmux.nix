{ pkgs, ... }:
{
  programs.bash = {
    interactiveShellInit = ''
      if [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
        exec tmux a
      fi
    '';
  };

  environment.systemPackages = with pkgs; [
    tmuxinator
    tmux-sessionizer
    fzf
  ];

  programs.tmux = {
    enable = true;
    customPaneNavigationAndResize = true;
    escapeTime = 0;
    keyMode = "vi";
    newSession = true;
    shortcut = "a";
    # this should be a punishable offence
    terminal = ''tmux-256color"
      set -g default-shell "${pkgs.fish}/bin/fish'';
    extraConfigBeforePlugins = ''
    '';
    extraConfig = ''
      set -g status-style bg=default
      set -g status-keys emacs
      set -g mouse on
      set -g status-right "=>> #H %H:%M"
      set -g allow-passthrough on

      bind C-o display-popup -E "sesh"
      bind C-j display-popup -E "tms switch"
      bind C-e display-popup 'fish -c "$(fish -c history | fzf)"'
      bind C-d display-popup -E 'fish -c dash'
      bind C-c 'copy-mode; send-keys -X search-backward "❯+"'
    '';
    plugins = with pkgs.tmuxPlugins; [
      extrakto
      fuzzback
      resurrect
      sensible
      urlview
      yank
    ];
  };
}
