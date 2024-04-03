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
      haskellPackages.hoogle
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
