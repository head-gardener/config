{ inputs, config, ... }:
{
  imports = [
    inputs.self.nixosModules.s3-mounts
  ];

  age.secrets.s3-torrent = {
    file = "${inputs.self}/secrets/s3-torrent.age";
  };

  personal.s3-mounts.torrent = {
    mountPoint = "/mnt/s3_torrent";
    passwdFile = config.age.secrets.s3-torrent.path;
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
