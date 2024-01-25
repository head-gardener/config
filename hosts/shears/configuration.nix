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
      sshfs
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

  hardware.bluetooth.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    libvdpau-va-gl
    vaapiIntel
    vaapiVdpau
  ];
}

