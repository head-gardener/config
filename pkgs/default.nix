inputs: pkgs: rec {
  # projectMSDL = pkgs.projectmsdl.override { preset = pkgs.projectm-presets-en-d; };

  cpanel = pkgs.callPackage ./cpanel { };

  perlHeaders = pkgs.callPackage ./perlHeaders.nix {
    # sources = with pkgs; [ ];
  };

  cloud-vm = pkgs.callPackage ./cloud-vm.nix {
    imgUrl = "https://cloud-images.ubuntu.com/noble/20251213/noble-server-cloudimg-amd64.img";
    imgHash = "sha256-iWx2Fk4+AHWDZMjqdTaj9l5/tezy8Zt8grrMeZ5xkGI=";
  };

  main-menu = pkgs.callPackage ./menu { };

  vaul7y = pkgs.callPackage ./vaul7y.nix { };

  nix-converter = inputs.nix-converter.packages.${pkgs.stdenv.hostPlatform.system}.default;

  vst3sdk = pkgs.callPackage ./vst3sdk.nix { };
  igorski-vsts = pkgs.callPackage ./igorski-vsts { inherit vst3sdk; };
}
