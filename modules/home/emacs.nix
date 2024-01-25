{ pkgs, inputs, ... }:
{

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      nordic-night-theme
      org
      ob-mermaid
      magit
    ];
    extraConfig = ''
      ${builtins.readFile "${inputs.self}/dots/emacs/init.el"}
      (setq ob-mermaid-cli-path "${pkgs.mermaid-cli}/bin/mmdc")
    '';
  };

}
