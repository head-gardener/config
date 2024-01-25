{ inputs, ... }:
{
  home.file = {
    ".config/nvim".source = "${inputs.self}/dots/nvim";
    ".config/nvim".recursive = true;

    ".config/i3/config".source = "${inputs.self}/dots/i3/config";

    ".config/fish".source = "${inputs.self}/dots/fish";
    ".config/fish".recursive = true;

    ".config/picom.conf".source = "${inputs.self}/dots/picom.conf";

    "Pictures/11.png".source = "${inputs.self}/dots/static/11.png";
  };
}
