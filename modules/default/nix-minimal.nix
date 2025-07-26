{
  system = {
    stateVersion = "25.05";
    copySystemConfiguration = false;
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "root" "hunter" ];
    };
    optimise = { automatic = true; };
  };
}
