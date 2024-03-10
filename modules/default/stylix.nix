{ inputs, pkgs, config, ... }:

{
  stylix = {
    image = "${inputs.self}/dots/static/11.png";

    polarity = "dark";
    base16Scheme = "${inputs.self}/dots/static/scheme.yaml";

    autoEnable = false;
    targets = {
      lightdm.enable = true;
    };

    opacity.terminal = 0.6;

    fonts = {
      monospace = {
        name = "Lilex Nerd Font";
        package = pkgs.lilex;
      };
      sansSerif = {
        name = "SourceCodePro";
        package = (pkgs.nerdfonts.override { fonts = [ "SourceCodePro" ]; });
      };
      sizes = {
        terminal = 10;
      };
    };

    cursor = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
      size = 24;
    };
  };
}
