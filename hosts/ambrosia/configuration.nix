{ inputs, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480s
    (inputs.self.lib.mkKeys inputs.self "hunter")
    "${inputs.self}/modules/github.nix"
    "${inputs.self}/modules/xmonad.nix"
    "${inputs.self}/modules/upower.nix"
    "${inputs.self}/modules/tailscale-client.nix"
    "${inputs.self}/modules/steam.nix"
  ];

  system.stateVersion = "24.05";

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
      sshfs
    ];
  };

  services = {
    blueman.enable = true;
  };

  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  hardware.bluetooth.enable = true;
}
