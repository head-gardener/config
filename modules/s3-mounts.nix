{ lib, pkgs, config, ... }:
let
  mkMount = name: cfg: {
    "${name}-bucket" = {
      device = name;
      mountPoint = cfg.mountPoint;
      fsType = "fuse./run/current-system/sw/bin/s3fs";
      noCheck = true;
      neededForBoot = false;
      options = [
        "_netdev"
        "allow_other"
        "use_path_request_style"
        "url=${cfg.url}"
        "passwd_file=${cfg.passwdFile}"
        "umask=${cfg.umask}"
      ];
    };
  };
in {
  options = {
    personal.s3-mounts = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          mountPoint = lib.mkOption { type = lib.types.str; };
          url = lib.mkOption {
            type = lib.types.str;
            default = "https://s3.backyard-hg.net";
          };
          passwdFile = lib.mkOption {
            type = lib.types.str;
          };
          after = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "networking.target" ];
          };
          umask = lib.mkOption {
            type = lib.types.str;
            default = "000";
          };
        };
      });
      default = { };
    };
  };

  config = {
    environment.systemPackages = [ pkgs.s3fs ];

    fileSystems =
      lib.mkMerge (lib.mapAttrsToList mkMount config.personal.s3-mounts);
  };
}
