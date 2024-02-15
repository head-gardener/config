{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      haskellPackages.hoogle
      commitlint
      deadnix
      editorconfig-checker
      lua-language-server
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
