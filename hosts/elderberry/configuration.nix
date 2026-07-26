{ inputs, pkgs, lib, ... }:

{
  imports = [
    inputs.self.nixosModules.providers-digitalocean
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

  environment.systemPackages = with pkgs; [
    fish
  ];

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = false;

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
