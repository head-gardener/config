{ pkgs, config, ... }: {
  warnings =
    if
      (! (builtins.elem "kvm-amd" config.boot.kernelModules))
      && (! (builtins.elem "kvm-intel" config.boot.kernelModules))
    then [ ''
      Vagrant is requested, but neither kvm-amd nor kvm-intel are enabled.
      Does this machine support virtualisation?
    '' ]
    else [];

  nixpkgs.allowUnfreeByName = [
    "packer"
    "vagrant"
  ];

  environment = {
    systemPackages = with pkgs; [
      guestfs-tools
      packer
      vagrant
    ];
    variables.VAGRANT_DEFAULT_PROVIDER = "libvirt";
  };

  users.users.hunter.extraGroups = [ "libvirtd" ];

  virtualisation.libvirtd = {
    enable = true;
  };
}
