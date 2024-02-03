{ pkgs, inputs, ... }:
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
      ob-mermaid
      ob-nix
      org
    ];
    extraConfig = ''
      ${builtins.readFile "${inputs.self}/dots/emacs/init.el"}
      (setq ob-mermaid-cli-path "${pkgs.mermaid-cli}/bin/mmdc")
    '';
  };
}
