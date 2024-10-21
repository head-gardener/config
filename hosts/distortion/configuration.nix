{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.musnix.nixosModules.musnix
    "${inputs.self}/modules/android-debug.nix"
    "${inputs.self}/modules/nvidia.nix"
    "${inputs.self}/modules/xmonad.nix"
    "${inputs.self}/modules/github.nix"
    "${inputs.self}/modules/hp-lj-1018.nix"
    "${inputs.self}/modules/docker.nix"
    "${inputs.self}/modules/steam.nix"
  ];

  environment.binsh = "${pkgs.dash}/bin/dash";
  musnix.enable = true;
  users.users.hunter.extraGroups = [ "audio" ];

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
      transmission-gtk
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
