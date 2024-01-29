{ lib, pkgs, inputs, ... }:

{
  imports = inputs.self.lib.ls ./home;

  home = {
    username = "hunter";
    homeDirectory = "/home/hunter";
    stateVersion = "23.11";
    packages = with pkgs; [
      arkpandora_ttf
      dconf
      easyeffects
      fish
      fzf
      fzy
      libnotify
      neofetch
      nix-prefetch-github
      obs-studio
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

  programs = {
    git = {
      enable = true;
      userName = "Head Gardener";
      userEmail = "trashbin2019np@gmail.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    home-manager.enable = true;
  };
}
