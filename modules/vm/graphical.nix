{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    glxinfo
  ];
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.extraConfig = "autologin-user=hunter";
}
