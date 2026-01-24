{
  stdenv,
  cmake,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
  freetype,
  fontconfig,
  curlFull,
  gtk3,
  libx11,
  libxrandr,
  libxinerama,
  libxext,
  libxcursor,
}:
let
  juce = fetchFromGitHub {
    owner = "juce-framework";
    repo = "JUCE";
    rev = "46c2a95905abffe41a7aa002c70fb30bd3b626ef";
    hash = "sha256-2Bx3QHRcYRPrnw2zZzwleUQ+Q1zOKr4bl8cmsT7vUNs=";
  };
in
stdenv.mkDerivation {
  pname = "delirion";
  version = "947d5ba328094984c2259e3c1f6772af0ade7f0d";

  src = fetchFromGitHub {
    owner = "igorski";
    repo = "delirion";
    rev = "947d5ba328094984c2259e3c1f6772af0ade7f0d";
    hash = "sha256-w13DfRyIAcfG+DHLRfEV/qUygLWfQkyPcUAHYmklYyo=";
  };

  preConfigure = ''
    ln -s ${juce} JUCE
  '';

  nativeBuildInputs = [
    cmake
    alsa-lib
    pkg-config
    freetype
    fontconfig
    curlFull.dev
    gtk3
    libx11
    libxrandr
    libxinerama
    libxext
    libxcursor
  ];
}
