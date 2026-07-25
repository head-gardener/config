# for uefi boot they require manually disabling secure boot via ovmf settings,
# accessible with f2
{ lib, ... }: {
  boot = {
    kernelParams = [
      "panic=1"
      "boot.panic_on_fail"
    ];
    initrd.kernelModules = [ "virtio_scsi" ];
    kernelModules = [
      "virtio_pci"
      "virtio_net"
    ];
  };

  services.cloud-init = {
    enable = true;
    network.enable = true;
    settings = {
      datasource_list = [
        "NoCloud"
        "None"
      ];
    };
  };

  networking = {
    useDHCP = lib.mkForce false;
    dhcpcd.enable = false;
    networkmanager.enable = false;
    wireless.enable = false;

    useNetworkd = true;
    interfaces = lib.mkForce { };
  };
}
