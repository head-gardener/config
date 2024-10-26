{ inputs, ... }:
{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      editorconfig
      haskell-mode
      magit
      nix-mode
      nordic-night-theme
      fzf
      use-package
      ob-nix
      org
    ];
    extraConfig = ''
      ${builtins.readFile "${inputs.self}/dots/emacs/init.el"}
    '';
  };
}
