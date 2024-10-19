{ pkgs, inputs, ... }:
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
      sus = "systemctl --user";
      sys = "systemctl";
      xi = "xargs -i";
    };
    interactiveShellInit =
      (builtins.readFile "${inputs.self}/dots/config.fish") + ''
        setenv LS_COLORS "${builtins.readFile pkgs.ls_colors}"
        function fish_right_prompt_loading_indicator
          echo (set_color '#aaa')' … '(set_color normal)
        end
        set sponge_delay 8

        abbr unfree --set-cursor=! "NIXPKGS_ALLOW_UNFREE=1 nix ! --impure"
        abbr nom-rebuild --set-cursor=! "nixos-rebuild ! --log-format internal-json -v 2>| nom --json"
      '';
    plugins = map nixplug (with pkgs.fishPlugins; [
      abbreviation-tips
      # async-prompt # doesn't work
      autopair
      done
      forgit-no-grc
      fzf-fish
      # gitnow
      puffer
      spark
      sponge
    ]);
  };
}
