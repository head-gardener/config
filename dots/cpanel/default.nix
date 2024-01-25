{ writeShellApplication, jq, pw-volume, libnotify, brightnessctl }:

writeShellApplication {
  name = "cpanel";

  runtimeInputs = [ jq pw-volume libnotify brightnessctl ];

  text = builtins.readFile ./cpanel.sh;
}
