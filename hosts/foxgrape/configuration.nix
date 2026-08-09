{
  inputs,
  ...
}:
# TODO: set cloud-init module allow list
# fix console
{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.kexec-installer
    inputs.self.nixosModules.providers-datalix
  ];

  personal.kexecInstaller = {
    firmware = "uefi";
    extraImports = [
      inputs.self.nixosModules.providers-datalix
    ];
  };

  networking.firewall.enable = true;
  networking.firewall.allowPing = false;
}
