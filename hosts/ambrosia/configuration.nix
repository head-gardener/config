{ inputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.github
    inputs.self.nixosModules.xmonad
    inputs.self.nixosModules.upower
    inputs.self.nixosModules.steam
  ];

  system.stateVersion = "24.11";

  systemd.services.tailscaled.wantedBy = lib.mkForce [];

  swapDevices = [{
    device = "/swapfile";
    size = 5120;
  }];

  boot = {
    tmp.useTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint = "/boot";
    };
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  users.users.hunter = {
    extraGroups = [ "networkmanager" ];
  };

  environment = {
    systemPackages = with pkgs; [
      sshfs
    ];
  };

  services = {
    blueman.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  hardware.bluetooth.enable = true;
}
