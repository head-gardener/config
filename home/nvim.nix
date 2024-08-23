{ inputs, pkgs, ... }:
let
  unstable = inputs.unstable.legacyPackages.${pkgs.system};
in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with unstable; [
      commitlint
      deadnix
      editorconfig-checker
      glow
      gnumake
      haskellPackages.hoogle
      lua-language-server
      lua5_1
      lua51Packages.luarocks
      nixd
      nixpkgs-fmt
      proselint
      statix
    ];
    plugins = with unstable.vimPlugins; [
      lazy-nvim
      sniprun
    ];
  };
}
