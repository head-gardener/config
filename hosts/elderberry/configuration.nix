{ inputs, pkgs, lib, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/digital-ocean-config.nix"
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.zram
  ];

  fileSystems."/" =
    { label = "nixos";
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "x-systemd.growfs"
      ];
    };

  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  networking.networkmanager.enable = false;

  environment.systemPackages = with pkgs; [
    fish
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = false;

  networking.useDHCP = lib.mkForce false;
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  programs = {
    atop = {
      enable = true;
      atopService.enable = true;
      atopRotateTimer.enable = true;
      netatop.enable = true;
      settings = {
        interval = 5;
        flags = "1fA";
      };
    };
  };
}
