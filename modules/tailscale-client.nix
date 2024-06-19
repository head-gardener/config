{ pkgs, ... }:

{
  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      tailscale
    ];
  };

  services.tailscale.enable = true;
}
