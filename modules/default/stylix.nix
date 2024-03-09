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

    cursor = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir";
    };
  };
}
