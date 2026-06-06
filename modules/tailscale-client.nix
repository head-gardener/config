{ pkgs, ... }:
{
  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      tailscale
    ];
  };

  personal.polkit.allowUnitControl."tailscaled.service".groups = [ "tailscale-ctl" ];
  users.groups.tailscale-ctl = { };

  services.tailscale.enable = true;
}
