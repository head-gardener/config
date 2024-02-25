{ inputs, pkgs, lib, ... }:
{
  programs = {
    nushell = {
      enable = true;
      configFile.source = "${inputs.self}/dots/nushell.nu";
      extraConfig = ''
        $env.LS_COLORS = "${builtins.readFile pkgs.ls_colors}"
      '';
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        nano = "nvim";
      };
    };
  };
}
