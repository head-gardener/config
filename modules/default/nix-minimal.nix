{
  system = {
    stateVersion = "24.05";
    copySystemConfiguration = false;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" "repl-flake" ];
      trusted-users = [ "root" "hunter" ];
    };
    optimise = { automatic = true; };
  };
}
