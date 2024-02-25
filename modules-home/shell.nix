{ inputs, ... }:
{
  programs = {
    carapace = {
      enable = true;
      enableFishIntegration = false;
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    starship = {
      enable = true;
      settings = {
        add_newline = true;
        format = ''
          $username$hostname$directory$git_branch$git_state$git_status$cmd_duration$nix_shell
          $shell $shlvl$character
        '';
        character = {
          success_symbol = "[❯](cyan)";
          error_symbol = "[❯](red)";
          vimcmd_symbol = "[❮](green)";
        };
        directory.style = "blue";
        git_branch.format = "[$branch](bright-black)";
        git_status = {
          format = "[[(*$conflicted$untracked$modified$staged$renamed$deleted)](218) ($ahead_behind$stashed)]($style)";
          style = "cyan";
          conflicted = "​";
          untracked = "​";
          modified = "​";
          staged = "​";
          renamed = "​";
          deleted = "​";
          stashed = "≡";
        };
        nix_shell = {
          disabled = false;
          impure_msg = "[impure shell](bold red)";
          pure_msg = "[pure shell](bold green)";
          unknown_msg = "[unknown shell](bold yellow)";
          format = "in [☃️ $state( \($name\))](bold blue) ";
        };
        shell = {
          disabled = false;
          format = "[$indicator]($style)";
        };
        shlvl = {
          disabled = false;
          format = "[$symbol]($style)";
          repeat = true;
          symbol = "❯";
          repeat_offset = 1;
          threshold = 0;
        };
      };
    };

    zoxide = {
      enable = true;
      options = [ "--cmd j" ];
    };
  };
}
