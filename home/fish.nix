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

      # e.g. `kubectl logs -f pod | foreach jq .`
      foreach = ''
        perl -E 'while (<STDIN>) { open(my $pipe, "|-", @ARGV); print $pipe $_; close $pipe or say $_; }'
      '';

      d = "docker";
      e = "$EDITOR";
      c = "docker compose";

      "компот" = "docker compose";
    };
    shellAbbrs = {
      loc = "XDG_CONFIG_HOME=~/config/dots";
      n = "nix";
      nbl = "nix build .";
      sus = "systemctl --user";
      sys = "systemctl";
      xi = "xargs -i";
      limit = "systemd-run --property MemoryMax=(math '1024 * 1024 * 1024 * 2') --property CPUQuota=100% --setenv=PATH=\"$PATH\" --same-dir --wait --pty --user";
    };
    interactiveShellInit =
      (builtins.readFile "${inputs.self}/dots/config.fish") + ''
        setenv LS_COLORS "${builtins.readFile pkgs.ls_colors}"
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
