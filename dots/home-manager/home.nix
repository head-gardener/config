{ lib, pkgs, inputs, ... }:

let
  personal = import ./overlay.nix { inherit pkgs; };
in {
  home = {
    username = "hunter";
    homeDirectory = "/home/hunter";
    stateVersion = "23.11";
    packages = with pkgs; [
      (personal.main-menu.override { inherit (personal) dmenu; })
      arkpandora_ttf
      bat
      bat
      brightnessctl
      dconf
      easyeffects
      fd
      fd
      fish
      fzf
      fzy
      libnotify
      neofetch
      nix-prefetch-github
      obs-studio
      personal.cpanel
      personal.dmenu
      pw-volume
      qpwgraph
      tree
      unzip
      vlc
      wineWowPackages.stable
      winetricks
      xclip
    ] ++ [
      cabal-install
      entr
      gcc
      haskell-language-server
      julia
      lua
      nixfmt
      stack
      stack
      inputs.unstable.legacyPackages."x86_64-linux".cargo
    ] ++ [
      gimp-with-plugins
      gmic
    ] ++ [
      firefox
      hunspell
      hunspellDicts.ru_RU
      libreoffice
      telegram-desktop
      thunderbird
    ];
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    theme = {
      name = "Graphite";
      package = pkgs.graphite-gtk-theme;
    };
  };

  home.file = {
    ".config/nvim".source = ../nvim;
    ".config/nvim".recursive = true;

    ".config/i3/config".source = ../i3/config;

    ".config/fish".source = ../fish;
    ".config/fish".recursive = true;

    ".config/picom.conf".source = ../picom.conf;

    "Pictures/11.png".source = ../static/11.png;
  };

  home.sessionVariables = { };

  programs = {
    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        nordic-night-theme
        org
        ob-mermaid
        magit
      ];
      extraConfig = ''
        ${builtins.readFile ../emacs/init.el}
        (setq ob-mermaid-cli-path "${pkgs.mermaid-cli}/bin/mmdc")
      '';
    };

    fish = {
      enable = true;
      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source
      '';
      plugins = let
        ghplug = url: {
          name = lib.last (lib.splitString "/" url);
          src = fetchGit { url = url; };
        };
      in builtins.map ghplug [
      ];
    };

    git = {
      enable = true;
      userName = "Head Gardener";
      userEmail = "trashbin2019np@gmail.com";
    };

    home-manager.enable = true;

    kitty = {
      enable = true;
      font = {
        package = personal.lilex;
        name = "Lilex Nerd Font Medium";
      };
      extraConfig = builtins.readFile ../kitty/kitty.conf;
      shellIntegration.enableFishIntegration = true;
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      # extraLuaConfig = lib.fileContents /home/hunter/config/nvim/init.lua;
      plugins = [{
        plugin = pkgs.vimPlugins.lazy-nvim;
        # config = ''
        #  packadd! nvim-colorizer.lua
        #  lua require 'colorizer'.setup()
        # '';
      }];
    };

    newsboat = {
      enable = true;
      extraConfig = ''
        notify-program "${pkgs.dunst}/bin/dunstify -a 'Newsboat' -u low '%t' '%u'"
      '';
      urls = [
        {
          title = "Ian Henry";
          url = "https://ianthehenry.com/feed.xml";
        }
        {
          title = "Willghatch";
          url = "http://www.willghatch.net/blog/feeds/all.rss.xml";
        }
        {
          title = "tweag nix";
          url = "https://www.tweag.io/rss-nix.xml";
        }
        {
          title = "tweag engineering";
          url = "https://www.tweag.io/rss.xml";
        }
        {
          title = "monday morning haskell";
          url = "https://mmhaskell.com/blog?format=rss";
        }
        {
          title = "Haskell Weekly";
          url = "https://haskellweekly.news/newsletter.atom";
        }
        {
          title = "planet haskell";
          url = "https://planet.haskell.org/rss20.xml";
        }
        {
          title = "Lilex";
          url = "https://github.com/mishamyrt/Lilex/tags.atom";
        }
        {
          title = "Conal Elliott's blog";
          url = "http://conal.net/blog/feed";
        }
        {
          title = "NixOS Weekly";
          url = "https://weekly.nixos.org/feeds/all.rss.xml";
        }
        {
          title = "Reasonably Polymorphic (Sandy Maguire)";
          url = "https://reasonablypolymorphic.com/atom.xml";
        }
      ];
    };

    tmux = {
      enable = true;
      terminal = "screen-256color";
      # package = unstable.tmux;
      shell = "${pkgs.fish}/bin/fish";
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
  };
}
