{
  imports = [
    ./graphical.nix
    ./.
  ];

  boot.initrd.kernelModules = [ ];
}
