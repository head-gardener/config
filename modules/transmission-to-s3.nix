{ inputs, pkgs, config, ... }:
{
  age.secrets.s3-torrent = {
    file = "${inputs.self}/secrets/s3-torrent.age";
  };

  environment.systemPackages = [ pkgs.s3fs ];

  fileSystems."torrent-bucket" = {
    device = "torrent";
    mountPoint = "/mnt/s3_torrent";
    fsType = "fuse./run/current-system/sw/bin/s3fs";
    noCheck = true;
    options = [
      "_netdev"
      "allow_other"
      "use_path_request_style"
      "url=https://s3.backyard-hg.xyz"
      "passwd_file=${config.age.secrets.s3-torrent.path}"
      "umask=000"
    ];
  };

  services.transmission = {
    enable = true;
    openFirewall = true;

    settings = {
      rpc-port = 9091;
      rpc-bind-address = "127.0.0.1";

      download-dir = "/mnt/s3_torrent/";
    };
  };
}
