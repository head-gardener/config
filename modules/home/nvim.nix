{ pkgs, inputs, system, ... }:
{
  # needed for telescopre-hoogle. can be done better by
  # I can't be bothered.
  home.packages = with pkgs; [ haskellPackages.hoogle ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      nixd
      nixpkgs-fmt
      deadnix
      statix
      commitlint
      editorconfig-checker
    ];
    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];
  };
}
