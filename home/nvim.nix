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
      gopls
      haskellPackages.hoogle
      lua-language-server
      lua51Packages.luarocks
      lua5_1
      nixd
      nixpkgs-fmt
      nodejs_latest
      proselint
      statix
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };
}
