inputs: pkgs: rec {
  # projectMSDL = pkgs.projectmsdl.override { preset = pkgs.projectm-presets-en-d; };

  cpanel = pkgs.callPackage ./cpanel { };

  perlHeaders = pkgs.callPackage ./perlHeaders.nix {
    # sources = with pkgs; [ ];
  };

  cloud-vm = pkgs.callPackage ./cloud-vm.nix { };

  main-menu = pkgs.callPackage ./menu { };

  vaul7y = pkgs.callPackage ./vaul7y.nix { };

  nix-converter = inputs.nix-converter.packages.${pkgs.stdenv.hostPlatform.system}.default;

  vst3sdk = pkgs.callPackage ./vst3sdk.nix { };
  igorski-vsts = pkgs.callPackage ./igorski-vsts { inherit vst3sdk; };

  jjazzlab = pkgs.callPackage ./jjazzlab.nix { };
}
