{
  lib,
  stdenv,
  bash,
  fetchFromGitHub,
  cmake,
  pkg-config,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-cursor,
  libxcb-keysyms,
  libxkbcommon,
  freetype,
  glib,
  cairo,
  pango,
  fontconfig,
  gtkmm3,
  sqlite,
}:
stdenv.mkDerivation {
  pname = "vst3sdk";
  version = "v3.7.11_build_10";

  src = fetchFromGitHub {
    owner = "steinbergmedia";
    repo = "vst3sdk";
    rev = "v3.7.14_build_55";
    hash = "sha256-Tyh8InZhriRh2bP9YqaXoVv33CYlwro9mpBKmoPNTfU=";
    fetchSubmodules = true;
  };

  preConfigure = ''
    export HOME="$(pwd)"
    sed -i "s|#!/bin/bash|#!${lib.getExe bash}|" \
      ./vstgui4/vstgui/uidescription/editing/createuidescdata.sh
  '';

  installPhase = ''
    # cmake cd-es to build for some reason
    cd ..
    rm -r .vst3
    cp -rv . $out
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    libx11
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-keysyms
    libxkbcommon
    freetype
    glib
    cairo
    pango
    fontconfig
    gtkmm3
    sqlite
  ];
}
