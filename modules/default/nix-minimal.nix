{
  system = {
    stateVersion = "24.11";
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
