{ python3Packages, stdenv, fetchFromGitHub, python3, features ? [ ], ttfautohint }:

stdenv.mkDerivation rec {
  pname = "lilex";
  version = "2.510";

  srcs = [
    (fetchFromGitHub {
      owner = "mishamyrt";
      repo = "Lilex";
      rev = version;
      hash = "sha256-lzoSzBtWIaxza7N06BXrl2h8F6tly8VaoDJ4xywTVa8=";
    })
  ];

  outputHash = "sha256-mnaifg6UvPnOXtaP4xZyrqfq3hSv6X4+5mTXXotKxlw=";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  configurePhase = ''
    python -m venv venv
    . venv/bin/activate
    pip install --no-cache-dir -r requirements.txt
  '';

  buildPhase = ''
    python ./scripts/lilex.py --features '${
      builtins.concatStringsSep "," features
    }' build
  '';

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/truetype/Lilex build/ttf/*.ttf
  '';

  buildInputs = with python3Packages; [ python3 fontmake ttfautohint cu2qu ];
}
