{ inputs, config, ... }:
{
  imports = [
    inputs.self.nixosModules.s3-mounts
  ];

  personal.va.templates.s3-torrent = {
    contents = ''
      {{ with secret "services/minio/torrent" }}{{ .Data.data.user }}:{{ .Data.data.pass }}{{ end }}
    '';
    for = "mnt-s3_torrent.mount";
  };

  personal.s3-mounts.torrent = {
    mountPoint = "/mnt/s3_torrent";
    passwdFile = config.personal.va.templates.s3-torrent.destination;
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
