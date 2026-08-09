{ inputs, modulesPath, ... }:

{
  imports = [
    inputs.self.nixosModules.providers-digitalocean
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.zram
    inputs.self.nixosModules.kexec-installer
  ];

  personal.kexecInstaller = {
    extraImports = [
      inputs.self.nixosModules.providers-digitalocean
      "${modulesPath}/virtualisation/digital-ocean-config.nix"
    ];
    flavor = "1g";
    unwrap = false;
  };

  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
}
