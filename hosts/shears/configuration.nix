{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    tmp.useTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      grub = {
        enable = false;
        useOSProber = true;
        default = "saved";
        efiSupport = true;
        device = "nodev";
      };
      efi.efiSysMountPoint = "/boot";
    };
  };

  networking = {
    firewall.enable = false;
    networkmanager.enable = true;
    wireless.enable = false;
  };

  users.users.hunter = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
  };

  environment = {
    systemPackages = with pkgs; [
      wget
      fd
      btrfs-progs
      atop
      git
      sshfs
      neovim
      pciutils
      tree
    ];
  };

  services = {
    blueman.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };

  virtualisation = {
    docker = {
      enable = true;
      storageDriver = "btrfs";
    };
  };

  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    optimise = {
      automatic = true;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  system.stateVersion = "23.11";

  hardware.bluetooth.enable = true;
}

