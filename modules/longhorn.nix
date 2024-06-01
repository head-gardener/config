# configuration required for running Longhorn on k8s
{ config, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nfs-utils ];
  services.openiscsi = {
    enable = true;
    name = "${config.networking.hostName}-initiatorhost";
  };
}
