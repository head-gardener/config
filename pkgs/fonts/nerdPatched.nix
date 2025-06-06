{ stdenv, nerd-font-patcher }:

# Patch all ttfs with nerdpatcher

{ font }:

stdenv.mkDerivation {
  pname = "${font.pname}NerdPatched";
  inherit (font) meta version;

  src = font;

  buildPhase = ''
    mkdir build
    cd build

    for f in $(find .. -type f -name "*.ttf"); do
      echo patching $f ...
      ${nerd-font-patcher}/bin/nerd-font-patcher -c --careful "$f"
    done
  '';

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/truetype ./*.ttf
  '';

  nativeBuildInputs = [ nerd-font-patcher ];
}

