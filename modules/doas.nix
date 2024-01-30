{ pkgs, ... }: {
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        keepEnv = true;
        persist = true;
        noPass = false;
      }
    ];
  };
}
