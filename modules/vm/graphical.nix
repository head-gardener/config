{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    glxinfo
  ];
  services.xserver.displayManager.lightdm.extraConfig = "autologin-user=hunter";
}
