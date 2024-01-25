{ writeShellApplication, kitty, julia, neovim, dmenu }:

writeShellApplication {
  name = "main-menu";

  runtimeInputs = [ kitty julia dmenu ];

  text = builtins.readFile ./main.sh;
}
