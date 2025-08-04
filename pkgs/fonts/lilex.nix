{ python3Packages, stdenv, fetchFromGitHub, python3, lib, writeText
, features ? [ ], ttfautohint }:

let
  version = "2.600";

  src = fetchFromGitHub {
    owner = "mishamyrt";
    repo = "Lilex";
    rev = version;
    hash = "sha256-JDJputJAraRVeloiuiMYdMOD48jIJ0NAqTMUeSCoU2s=";
  };

  conf = writeText "lilex_config.yaml" (lib.generators.toYAML { } {
    source = "./sources";
    output = "./build";
    family = {
      "Lilex.glyphs" = { };
      "Lilex-Italic.glyphs" = { };
    };
  });
in stdenv.mkDerivation {
  pname = "lilex";
  inherit version src;

  outputHash = "sha256-QYnv0kljEynUYcjZ8Xq6OXBXT2xu+/3cB63fFSYflXM=";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  buildPhase = ''
    python -m venv venv
    . venv/bin/activate
    sed -i '/pylint/d;/ruff/d;/glyphsLib/d' requirements.txt
    pip install --no-cache-dir -r requirements.txt
    python ./scripts/font.py --config ${conf} build
  '';

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/truetype/Lilex build/ttf/*.ttf
  '';

  buildInputs = with python3Packages; [
    python3
    ttfautohint
    glyphslib
    fontmake
  ];
}
