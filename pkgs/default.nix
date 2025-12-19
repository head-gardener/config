inputs: pkgs: {
  # projectMSDL = pkgs.projectmsdl.override { preset = pkgs.projectm-presets-en-d; };

  cpanel = pkgs.callPackage ./cpanel { };

  perlHeaders = pkgs.callPackage ./perlHeaders.nix {
    # sources = with pkgs; [ ];
  };

  main-menu = pkgs.callPackage ./menu { };

  vaul7y = pkgs.callPackage ./vaul7y.nix { };

  nix-converter = inputs.nix-converter.packages.${pkgs.stdenv.hostPlatform.system}.default;

  inherit (pkgs.fishPlugins) done abbreviation-tips forgit-no-grc gitnow spark;
}
