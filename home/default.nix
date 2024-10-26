{ lib, pkgs, inputs, ... }:

{
  imports =
    (builtins.filter (x: !(lib.hasSuffix "default.nix" x))
      (inputs.self.lib.ls "${inputs.self}/home"))
    ++ [ ];

  home = {
    username = "hunter";
    stateVersion = "24.05";
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
      chromium
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
