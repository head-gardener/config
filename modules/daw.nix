{ pkgs, inputs, ... }:
let
  pluginPaths = [
    "/lib/vst"
    "/lib/vst3"
    "/lib/lv2"
    "/lib/lxvst"
    "/lib/ladspa"
  ];

  repoToSFZ =
    args:
    pkgs.stdenvNoCC.mkDerivation (
      let
        name = "${args.owner}-${args.repo}";
      in
      {
        pname = name;
        version = args.rev;

        src = pkgs.fetchFromGitHub args;

        installPhase = ''
          mkdir -p "$out/opt/sfz/$name"
          cp -r . "$out/opt/sfz/$name/"
        '';
      }
    );
in
{
  imports = [ inputs.musnix.nixosModules.musnix ];

  nixpkgs.allowUnfreeByName = [
    "reaper"
    "vst2-sdk"
  ];

  environment.pathsToLink = pluginPaths ++ [
    "/opt/sfz"
  ];

  musnix.enable = true;
  users.users.hunter.extraGroups = [ "audio" ];

  environment.systemPackages = with pkgs; [
    bespokesynth-with-vst2
    cardinal
    ffmpeg
    guitarix
    hydrogen
    reaper
    inputs.unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.sfizz-ui

    (repoToSFZ {
      owner = "sfzinstruments";
      repo = "SplendidGrandPiano";
      rev = "1c595d827b7fd7f0be3134aaed0f90b3662a09cf";
      hash = "sha256-wVP0IZEDlnXyxzrf+9tN/hPSV5jKg4CS5tJC/N2XX7Y=";
    })
    (repoToSFZ {
      owner = "sfzinstruments";
      repo = "karoryfer.emilyguitar";
      rev = "b4920dc662fd9cad6dcaccdeecffdd91c8725d8c";
      hash = "sha256-oFxC7dbVqjkmdYvR7qnfmWTvtlC8mjPNUggn6MYXVTI=";
    })
    (repoToSFZ {
      owner = "sfzinstruments";
      repo = "karoryfer.gogodze-phu-vol-ii";
      rev = "69a0274cdc39c99c3098cde1bc3789690de86d62";
      hash = "sha256-27ZoDI3hqPp25H0XzQl6atnwfEKBSrx8YI1mFGtEGAI=";
    })

    aether-lv2
    airwindows
    calf
    carla
    chow-centaur
    chow-kick
    chow-phaser
    chow-tape-model
    distrho-ports
    dragonfly-reverb
    geonkick
    helm
    lsp-plugins
    neural-amp-modeler-lv2
    ninjas2
    oxefmsynth
    surge-XT
    tap-plugins
    x42-plugins
    zam-plugins
  ];
}
