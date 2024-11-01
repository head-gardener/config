{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.github
    inputs.self.nixosModules.xmonad
    inputs.self.nixosModules.upower
    inputs.self.nixosModules.steam
  ];

  services.easyeffects.enable = true;
  boot.kernel.sysctl = { "vm.swappiness" = 20; };

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

  hardware.bluetooth.enable = true;
}
