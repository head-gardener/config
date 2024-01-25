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
      efi.efiSysMountPoint = "/boot";
    };
  };

  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      sshfs
      networkmanager-openvpn
    ];
  };

  users.users.hunter = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "audio" ];
  };

  programs = {
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    dconf.enable = true;
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };

  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  nix = {
    settings = {
      substituters = [
        "http://blueberry"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "blueberry:yZO3C9X6Beti/TAEXxoJaMHeIP3jXYVWscrYyqthly8="
      ];
    };
  };
}
