{ pkgs, inputs, ... }:
{

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      editorconfig
      magit
      nix-mode
      nordic-night-theme
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
