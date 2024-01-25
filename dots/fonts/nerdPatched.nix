{ stdenv, fontforge, nerd-font-patcher }:

# Patch all ttfs with nerdpatcher

{ font }:

stdenv.mkDerivation {
  name = "${font.pname}NerdPatched";
  inherit (font) meta version;

  src = font;

  buildPhase = ''
    mkdir build
    cd build

    for f in $(find .. -type f -name "*.ttf"); do
      echo patching $f ...
      ${nerd-font-patcher}/bin/nerd-font-patcher\
        -c --careful --has-no-italic "$f"
    done
  '';

  installPhase = ''
    install -m 444 -Dt $out/share/fonts/truetype ./*.ttf
  '';

  buildInputs = [ nerd-font-patcher ];
}

