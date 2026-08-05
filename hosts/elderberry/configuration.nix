{ inputs, ... }:

{
  imports = [
    inputs.self.nixosModules.providers-digitalocean
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.zram
    inputs.self.nixosModules.installer-toplevel
  ];

  personal.installer = {
    extraImports.all = [
      inputs.self.nixosModules.providers-digitalocean
      {
        services.do-agent.enable = false;
        services.openssh.enable = false;
        virtualisation.digitalOcean.rebuildFromUserData = false;
      }
    ];
  };

  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
}
