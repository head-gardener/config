{ config, lib, ... }:
let
  detect = lib.pipe config.fileSystems [
    lib.attrsToList
    (builtins.filter (x: x.value.fsType == "btrfs"))
    (map (x: x.name))
  ];
  enable = builtins.length detect != 0;
  cfg = config.btrfs.autoConfigure;
in
{
  options.btrfs.autoConfigure.disable = lib.mkOption {
    default = false;
    description = "Whether to skip setting btrfs-related configuration"
      + " regardless of the file system used";
    type = lib.types.bool;
  };


  config = lib.mkIf (enable && !cfg.disable) {
    services = {
      btrfs.autoScrub = {
        enable = true;
        interval = "weekly";
        fileSystems = detect;
      };
    };

    # might not work idk
    virtualisation.docker.storageDriver = "btrfs";
  };
}
