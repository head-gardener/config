{ inputs, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
  ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = false;

  networking.firewall = {
    allowPing = true;
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
  };
}
