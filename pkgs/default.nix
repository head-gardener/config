inputs: pkgs: {
  # projectMSDL = pkgs.projectmsdl.override { preset = pkgs.projectm-presets-en-d; };

  cpanel = pkgs.callPackage ./cpanel { };

  perlHeaders = pkgs.callPackage ./perlHeaders.nix {
    # sources = with pkgs; [ ];
  };

  cloud-vm = pkgs.callPackage ./cloud-vm.nix {
    imgUrl = "https://cloud-images.ubuntu.com/noble/20251213/noble-server-cloudimg-amd64.img";
    imgHash = "sha256-K1+Q/+gYDe9gHAIch05V2DA+i8v8Zv7iuUQU9DrF6x8=";
  };

  main-menu = pkgs.callPackage ./menu { };

  vaul7y = pkgs.callPackage ./vaul7y.nix { };

  nix-converter = inputs.nix-converter.packages.${pkgs.stdenv.hostPlatform.system}.default;

  inherit (pkgs.fishPlugins) done abbreviation-tips forgit-no-grc gitnow spark;
}
