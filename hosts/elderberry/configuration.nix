{ inputs, pkgs, ... }:

{
  imports = [
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.zram
  ];

  swapDevices = [{
    device = "/swapfile";
    size = 5120;
  }];

  networking.networkmanager.enable = false;

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
