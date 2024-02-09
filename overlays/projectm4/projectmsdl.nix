{ stdenv
, fetchFromGitHub
, SDL2
, poco
, cmake
, projectm4
, lib
, projectm-presets-cotc
, preset ? projectm-presets-cotc
}:

stdenv.mkDerivation rec {
  pname = "projectmsdl";
  version = "2.0-pre1";

  src = fetchFromGitHub {
    owner = "kblaschke";
    repo = "frontend-sdl2";
    rev = "854eebaa26d91042ba8f097ec5e409bdcea78383";
    hash = "sha256-fcbpzjj5P6V8I2l76nKZaclCXjark/BWw9HRewI7kHU";
  };

  patches = [
    ./no-sdl2main.patch
  ];

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    SDL2
    poco
    projectm4
  ];

  fixupPhase = lib.optionalString (lib.isDerivation preset || lib.isPath preset) ''
    sed -i -e "s,projectM.presetPath = .*$,projectM.presetPath = ${preset}," $out/projectMSDL.properties
    sed -i -e "s,projectM.texturePath = .*$,projectM.texturePath = ${preset}," $out/projectMSDL.properties
  '';


  cmakeFlags = [
    "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=${placeholder "out"}/bin"
  ];

  meta = {
    homepage = "https://github.com/kblaschke/frontend-sdl2";
    description = "SDL2-based standalone application that turns your desktop audio into awesome visuals.";
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    mainProgram = "projectMSDL";
    maintainers = with lib.maintainers; [ ];
    longDescription = ''
      This is a reference implementation of an applicatiaon that makes use of the projectM music visualization library.
      It will listen to audio input and produce mesmerizing visuals. Some commands are supported.
    '';
  };
}
