{ pkgs, inputs, ... }:
let
  pluginPaths =
    [ "/lib/vst" "/lib/vst3" "/lib/lv2" "/lib/lxvst" "/lib/ladspa" ];
in {
  imports = [ inputs.musnix.nixosModules.musnix ];

  nixpkgs.allowUnfreeByName = [ "reaper" "vst2-sdk" ];

  environment.pathsToLink = pluginPaths;

  musnix.enable = true;
  users.users.hunter.extraGroups = [ "audio" ];

  environment.systemPackages = with pkgs; [
    bespokesynth-with-vst2
    cardinal
    ffmpeg
    guitarix
    hydrogen
    reaper

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
