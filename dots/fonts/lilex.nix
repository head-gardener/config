{ python3Packages, stdenv, fetchFromGitHub, python3, features ? [ ], ttfautohint}:

stdenv.mkDerivation {
  pname = "lilex";
  version = "2.400";

  srcs = [(fetchFromGitHub {
    owner = "mishamyrt";
    repo = "Lilex";
    rev = "0bb53c1458f3a511feb1ced97b5682c014b02397";
    hash = "sha256-xanRGw6jTdvy0agZAzUCqh9NeP9Sji+temUPtPr+KSc=";
  })];

  outputHash = "sha256-+3qVLFZ8OAb00pnajo0Fh6UQZ1H0jDlcxp0txauB3vY=";
  outputHashAlgo = "sha256";
  outputHashMode= "recursive";

  configurePhase = ''
    python -m venv venv
    . venv/bin/activate
    cp ${./requirements.txt} requirements.txt
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
