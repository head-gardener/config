{ pkgs, ... }:
{
  programs.bash = {
    interactiveShellInit = ''
      if [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
        exec tmux a
      fi
    '';
  };

  environment.systemPackages = with pkgs; [ tmuxinator ];

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
