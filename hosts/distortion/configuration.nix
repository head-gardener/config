{ config, pkgs, lib, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  boot = {
    tmp.useTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      grub = {
        enable = false;
        useOSProber = false;
        default = "saved";
        efiSupport = true;
        device = "nodev";
      };
      efi = {
        efiSysMountPoint = "/boot";
        canTouchEfiVariables = true;
      };
    };
  };

  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      sshfs
      networkmanager-openvpn
    ];
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
  };

  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };
}
