{
  fetchFromGitHub,
  jdk25,
  maven,
  makeWrapper,
  makeDesktopItem,
  fluidsynth,
}:
let
  soundfont = builtins.fetchurl {
    url = "https://archive.org/download/jjazz-lab-sound-font/JJazzLab-SoundFont.sf2";
    sha256 = "sha256-UKueqnEd068CVEQg91iBvoM6h2+QUcYNgMIx9jh9jYA=";
  };
  desktopItem = makeDesktopItem {
    name = "jjazzlab";
    desktopName = "JJazzLab";
    exec = "jjazzlab";
    comment = "A complete and open application for automatic backing tracks generation.";
    categories = [ "AudioVideo" "X-AudioEditing" ];
  };
in
maven.buildMavenPackage {
  pname = "jjazzlab";
  version = "5.1";

  src = fetchFromGitHub {
    owner = "jjazzboss";
    repo = "JJazzLab";
    rev = "5.1";
    hash = "sha256-BFv7BWfgAQ+TOJwVvmQR3Pyzn9e0uje7wNsvEjD7wd4=";
  };

  mvnHash = "sha256-AtJQrMsTXdybOjftSIS/UkYYfAFD/UU3gEFPflg3v+4=";
  mvnJdk = jdk25;

  nativeBuildInputs = [ makeWrapper ];

  preConfigure = ''
    ln -s ${soundfont} \
      plugins/FluidSynthEmbeddedSynth/src/main/soundfont/JJazzLab-SoundFont.sf2
  '';

  installPhase = ''
    runHook preInstall

    cp -rv ./app/application/target/jjazzlab $out
    makeWrapper $out/bin/jjazzlab $out/bin/jjazzlab-wrapped \
      --add-flags '--jdkhome ${ jdk25 }' \
      --add-flags '-J-Dfluidsynthlib.path=${ fluidsynth }/lib/libfluidsynth.so'

    mkdir -p $out/share/applications
    cp ${desktopItem}/share/applications/* $out/share/applications/

    runHook postInstall
  '';
}
