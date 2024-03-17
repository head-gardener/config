{ config, inputs, pkgs, ... }:
{
  age.secrets.s3-backup = {
    file = "${inputs.self}/secrets/s3-backup.age";
  };

  environment.systemPackages = [ pkgs.s3fs ];

  fileSystems."backups-bucket" = {
    device = "backup";
    mountPoint = "/mnt/s3_backup";
    fsType = "fuse./run/current-system/sw/bin/s3fs";
    noCheck = true;
    options = [ "_netdev" "allow_other" "use_path_request_style" "url=https://s3.backyard-hg.xyz" "passwd_file=${config.age.secrets.s3-backup.path}" "umask=0177" ];
  };
}
