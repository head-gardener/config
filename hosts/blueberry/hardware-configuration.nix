# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, modulesPath, ... }:
let
  btrfsRoot = "/dev/disk/by-label/NIXOS";
  backupRoot = "/dev/disk/by-label/BACKUP2";
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/mnt/btr_backup" =
    { device = backupRoot;
      fsType = "btrfs";
      options = [ "subvolid=5" ];
    };

  fileSystems."/mnt/btr_pool" =
    { device = btrfsRoot;
      fsType = "btrfs";
      options = [ "subvolid=5" ];
    };

  fileSystems."/" =
    {
      device = btrfsRoot;
      fsType = "btrfs";
      options = [ "subvol=root" ];
    };

  fileSystems."/persistent" =
    {
      device = btrfsRoot;
      neededForBoot = true;
      fsType = "btrfs";
      options = [ "subvol=persistent" ];
    };

  fileSystems."/var" =
    {
      device = btrfsRoot;
      fsType = "btrfs";
      options = [ "subvol=var" ];
    };

  fileSystems."/nix" =
    {
      device = btrfsRoot;
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/260C-04D8";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-label/SWAP1"; }];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp2s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp0s20f0u8u2.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
