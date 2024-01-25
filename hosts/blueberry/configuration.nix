{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };

  networking.networkmanager.enable = false;

  users.users.hunter = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [
    ];
  };

  environment.systemPackages = with pkgs; [
    atop
    git
    grc
    less
    neovim
    nix-tree
    ntfs3g
    rsync
    tree
    wget
  ];

  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system = {
    copySystemConfiguration = false;
    stateVersion = "23.11";
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:head-gardener/config";
      flags = [ ];
    };
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "trashbin2019np@gmail.com";
    };
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      interval = "weekly";
      fileSystems = [ "/" ];
    };

    cron = {
      enable = true;
      systemCronJobs = [
        "0 6 * * * hunter . /etc/profile; /home/hunter/cache/build.sh"
      ];
    };

    nix-serve = {
      enable = true;
      secretKeyFile = "/home/hunter/nix-serve/cache-priv.pem";
    };
  };

  programs = {
    atop = {
      enable = true;
      atopService.enable = true;
      atopRotateTimer.enable = true;
      netatop.enable = true;
      settings = {
        interval = 5;
        flags = "a1f";
      };
    };

    tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      newSession = true;
      escapeTime = 50;
    };
  };
}
