{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.musnix.nixosModules.musnix
    inputs.self.nixosModules.android-debug
    inputs.self.nixosModules.nvidia
    inputs.self.nixosModules.xmonad
    inputs.self.nixosModules.github
    inputs.self.nixosModules.docker
    inputs.self.nixosModules.steam
  ];

  environment.binsh = "${pkgs.dash}/bin/dash";
  musnix.enable = true;
  users.users.hunter.extraGroups = [ "audio" ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_470;

  btrfs.autoConfigure.compressStore = true;

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

    nixStoreMountOpts = [
      "noatime"
    ];
  };

  environment = {
    pathsToLink = [ "/libexec" ];
    systemPackages = with pkgs; [
      transmission_4-gtk
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
