{
  lib,
  config,
  pkgs,
  ...
}:
{
  boot.loader.efi.canTouchEfiVariables = false;

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.repart.enable = true;
  boot.growPartition = lib.mkForce false;

  image.repart = {
    name = "root";

    mkfsOptions.btrfs = [
      "--shrink"
      "-m"
      "single"
    ];

    compression = {
      enable = true;
      algorithm = "zstd";
      level = 19;
    };

    partitions."20-root" = {
      storePaths = [ config.system.build.toplevel ];
      contents."/nix-path-registration".source = "${
        pkgs.closureInfo { rootPaths = [ config.system.build.toplevel ]; }
      }/registration";
      repartConfig = {
        Type = "root";
        Format = "btrfs";
        Label = "nixos";
        Minimize = "guess";
        GrowFileSystem = true;
      };
    };
  };

  systemd.repart.partitions."20-root" = {
    Type = "root";
  };

  # TODO: make this a unit
  boot.postBootCommands = ''
    if [ -f /nix-path-registration ]; then
      ${config.nix.package.out}/bin/nix-store --load-db < /nix-path-registration
      ${config.nix.package.out}/bin/nix-env -p /nix/var/nix/profiles/system \
      --set /run/current-system
      rm -f /nix-path-registration
    fi
  '';

  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/nixos";
    fsType = "btrfs";
    options = [ "x-systemd.growfs" ];
  };
}
