{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    lilex
    (nerdfonts.override { fonts = [ "SourceCodePro" ]; })
  ];
}
