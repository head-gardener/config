{ lib, modulesPath, ... }: {
  imports = [
    "${modulesPath}/virtualisation/digital-ocean-config.nix"
  ];

  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  networking.useDHCP = lib.mkForce false;
  networking.networkmanager.enable = false;
}
