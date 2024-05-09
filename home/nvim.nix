{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      commitlint
      deadnix
      editorconfig-checker
      glow
      gnumake
      haskellPackages.hoogle
      lua-language-server
      lua5_1
      nixd
      nixpkgs-fmt
      proselint
      statix
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };
}
