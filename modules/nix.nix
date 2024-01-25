{
  system = {
    stateVersion = "23.11";
    copySystemConfiguration = false;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
