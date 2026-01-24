{
  symlinkJoin,
  callPackage,
  fetchFromGitHub,
  vst3sdk,

  VSTSID ? callPackage ./generic-vst3sdk.nix {
    pname = "VSTSID";
    version = "87d18e65218dc70c63c63b4f7e08c9bfad94399e";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "VSTSID";
      rev = "87d18e65218dc70c63c63b4f7e08c9bfad94399e";
      hash = "sha256-FNlOOd5aJYKkN2tdxR7Hs0Q2hv+Vjjm7iyhEAuhMjfA=";
    };

    inherit vst3sdk;
  },
  darvaza ? callPackage ./generic-vst3sdk.nix {
    pname = "darvaza";
    version = "b935871960040bd50b962864442af6daf6331aca";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "darvaza";
      rev = "b935871960040bd50b962864442af6daf6331aca";
      hash = "sha256-NvPpTEBNGhz6fcbfJndRSWVcEbnTZafFxkFAGUMNy+Q=";
    };

    inherit vst3sdk;
  },
  delirion ? callPackage ./delirion.nix {},
  fogpad ? callPackage ./generic-vst3sdk.nix {
    pname = "fogpad";
    version = "2e861917324fc5b556d4c28b97bb3acc83663d56";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "fogpad";
      rev = "2e861917324fc5b556d4c28b97bb3acc83663d56";
      hash = "sha256-viZldEegL8Jc1OKYo4fbmo/bc+mBMDCI8LfTVw5v2gs=";
    };

    inherit vst3sdk;
  },
  homecorruptor ? callPackage ./generic-vst3sdk.nix {
    pname = "homecorruptor";
    version = "7b594e6a3bf2c4946a6f3c13d4cc8f34cd605fd0";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "homecorrupter";
      rev = "7b594e6a3bf2c4946a6f3c13d4cc8f34cd605fd0";
      hash = "sha256-jFD0orWRELJE5CKAxqNF8KKtS9kMnAzrqZTPX8FoRUQ=";
    };

    inherit vst3sdk;
  },
  rechoir ? callPackage ./generic-vst3sdk.nix {
    pname = "rechoir";
    version = "583d9a6297ee101481f67bd5d92c4e2447e34cc9";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "rechoir";
      rev = "583d9a6297ee101481f67bd5d92c4e2447e34cc9";
      hash = "sha256-khVKTGlhPuuBb51A/njcnGKNVMixDPUUsRIoMKGmyY0=";
    };

    inherit vst3sdk;
  },
  transformant ? callPackage ./generic-vst3sdk.nix {
    pname = "transformant";
    version = "9415de211748d01d85ae9c06ea5d7fa79fb11589";

    src = fetchFromGitHub {
      owner = "igorski";
      repo = "transformant";
      rev = "9415de211748d01d85ae9c06ea5d7fa79fb11589";
      hash = "sha256-GSZ98Q2tjpbVzkyxasX1lQiTfqZ7eOiAJCNFbpLvsCo=";
    };

    inherit vst3sdk;
  },
}:
symlinkJoin {
  name = "igorski-vsts";
  paths = [
    # doesn't run
    VSTSID
    darvaza
    # doesn't link
    # delirion
    fogpad
    # doesn't run
    homecorruptor
    rechoir
    transformant
  ];
}
