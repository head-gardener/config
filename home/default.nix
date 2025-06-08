{ lib, pkgs, inputs, ... }:

{
  imports =
    (builtins.filter (x: !(lib.hasSuffix "default.nix" x))
      (inputs.self.lib.ls "${inputs.self}/home"))
    ++ [ ];

  home = {
    username = "hunter";
    stateVersion = "24.11";
    packages = with pkgs; [
      arkpandora_ttf
      bemoji
      dconf
      easyeffects
      fish
      fzy
      libnotify
      nautilus
      neofetch
      nix-prefetch-github
      obs-studio
      ripdrag
      tree
      unzip
      vlc
      wineWowPackages.stable
      winetricks
      xclip
    ] ++ [
      cabal-install
      cloc
      entr
      gcc
      haskell-language-server
      inputs.unstable.legacyPackages.${system}.cargo
      julia
      lua
      nixfmt
      stack
      stack
    ] ++ [
      feh
      gimp-with-plugins
      gmic
      graphviz
    ] ++ [
      chromium
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
  };

  programs = {
    yazi.enable = true;

    home-manager.enable = true;
  };
}
