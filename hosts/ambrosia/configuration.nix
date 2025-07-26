{ inputs, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.daw
    inputs.self.nixosModules.github
    inputs.self.nixosModules.steam
    inputs.self.nixosModules.upower
    inputs.self.nixosModules.awesomewm
    inputs.self.nixosModules.xmonad
    inputs.self.nixosModules.zram
  ];

  system.stateVersion = "25.05";

  systemd.services.tailscaled.wantedBy = lib.mkForce [];

  swapDevices = [{
    device = "/swapfile";
    size = 16384;
  }];

  boot = {
    tmp.useTmpfs = true;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
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
      inputs.self.packages.${pkgs.system}.vaul7y
      sshfs
    ];
  };

  services = {
    blueman.enable = true;
    xserver.windowManager.myxmonad.extraCommands = ''
      xinput set-prop "10" "libinput Accel Speed" 1
    '';
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  hardware.bluetooth.enable = true;
}
