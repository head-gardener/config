{ inputs, ... }: {
  services.xmobar = {
    enable = true;
    config = builtins.readFile "${inputs.self}/dots/xmobar/xmobarrc";
  };
}
