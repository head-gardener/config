{ inputs, ... }:
{
  programs = {
    nushell = {
      enable = true;
      configFile.source = "${inputs.self}/dots/nushell.nu";
      shellAliases = {
        vi = "nvim";
        vim = "nvim";
        nano = "nvim";
      };
    };
  };
}
