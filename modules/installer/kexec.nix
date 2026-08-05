{ modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/netboot/netboot.nix"
    "${modulesPath}/profiles/perlless.nix"
  ];

  boot.kernelParams = [
    "installer.image_url="
    "installer.target_disk="
  ];

  services.userborn = {
    enable = true;
    static = true;
  };

  # brought in by netboot which doesn't gate on nix.enabled
  systemd.services.register-nix-paths.enable = false;

  systemd.services.installer.script = lib.mkBefore ''
    for o in $(</proc/cmdline); do
      case "$o" in
        installer.image_url=*) [ -n "$image_url" ] || image_url="''${o#*=}" ;;
        installer.target_disk=*) [ -n "$target_disk" ] || target_disk="''${o#*=}" ;;
      esac
    done
  '';
}
