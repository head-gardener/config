{ inputs, ... }: {
  imports = [
    inputs.self.nixosModules.vm-graphical
    inputs.self.nixosModules.vm-minimal
  ];

  boot.initrd.kernelModules = [ ];
}
