{ lib, pkgs, inputs, ... }:

{
  imports = inputs.self.lib.ls ./home;

  home = {
    username = "hunter";
    stateVersion = "23.11";
    packages = with pkgs; [
      arkpandora_ttf
      bemoji
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
      inputs.unstable.legacyPackages.${system}.cargo
    ] ++ [
      gimp-with-plugins
      gmic
      graphviz
    ] ++ [
      firefox
      hunspell
      hunspellDicts.ru_RU
      ktouch
      libreoffice
      telegram-desktop
      thunderbird
    ];
  };

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
  };

  programs = {
    yazi.enable = true;

    home-manager.enable = true;
  };
}
