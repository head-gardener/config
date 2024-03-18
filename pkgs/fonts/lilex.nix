{ python3Packages, stdenv, fetchFromGitHub, python3, features ? [ ], ttfautohint }:

stdenv.mkDerivation {
  pname = "lilex";
  version = "2.400";

  srcs = [
    (fetchFromGitHub {
      owner = "mishamyrt";
      repo = "Lilex";
      rev = "0c63d0d919201078c6b8f2364c295a3c034da503";
      hash = "sha256-WJcLhrEpl4Qy+Mhw7Sajh6GO1GpTCVB6bjnpjxlFnSI= ";
    })
  ];

  outputHash = "sha256-06G/WVskq3RihPfTa6reL31HUu8EayMcIjjJ/mzDx8o=";
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
