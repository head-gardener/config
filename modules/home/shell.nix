{ inputs, ... }:
{
  programs = {
    carapace = {
      enable = true;
    };

    dircolors = {
      enable = true;
      extraConfig = builtins.readFile "${inputs.self}/dots/dir_colors";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
      };
    };

    zoxide = {
      enable = true;
      options = [ "--cmd j" ];
    };
  };
}
