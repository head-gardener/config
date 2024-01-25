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
      wget
      fd
      atop
      git
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

  fileSystems = {
    "/home" = {
      device = "/dev/disk/by-label/home";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
    };
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };

  services = {
    openssh.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };

  networking = {
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = false;
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    settings = {
      substituters = [
        "http://blueberry"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "blueberry:yZO3C9X6Beti/TAEXxoJaMHeIP3jXYVWscrYyqthly8="
      ];
    };
    optimise = {
      automatic = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system = {
    copySystemConfiguration = false;
    stateVersion = "23.11";
  };
}
