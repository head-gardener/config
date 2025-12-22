{
  stdenv,
  perl,
  glibc,
  linuxHeaders,
  sources ? [
    glibc.dev
    linuxHeaders
  ],
}:
stdenv.mkDerivation {
  pname = "perlHeaders";
  version = "0.0.1";

  buildInputs = [ perl ];

  dontUnpack = true;
  buildPhase = ''
    dst="$out/lib/perl$(perl -E '$_ = $^V; s/^v(.).*/$1/; print')/site_perl/$(perl -E '$_ = $^V; s/^v//; print')"
    mkdir -p "$dst"
    ${builtins.concatStringsSep "\n" (
      map (s: ''
        cd "${s}"
        [ -d "${s}/include" ] && cd "${s}/include"
        h2ph -d "$dst" -r *
        if [ -d "${s}/include/linux" ]; then
          cd "${s}/include/linux"
          h2ph -d "$dst" -r *
        fi
      '') sources
    )}
  '';

  passthru = {
    perlModule = { };
  };
}
