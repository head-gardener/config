{ inputs, config, ... }:
let
  downloadDir = "/mnt/s3_torrent";
in {
  imports = [ inputs.self.nixosModules.s3-mounts ];

  personal.va.templates.s3-torrent = {
    contents = ''
      {{ with secret "services/minio/torrent" }}{{ .Data.data.user }}:{{ .Data.data.pass }}{{ end }}
    '';
    for = "mnt-s3_torrent.mount";
  };

  personal.s3-mounts.torrent = {
    after = [ "vault-agent-machine.service" ];
    mountPoint = downloadDir;
    passwdFile = config.personal.va.templates.s3-torrent.destination;
  };

  systemd.services.rtorrent.after = [ "mnt_s3-torrent.mount" ];

  services.rtorrent = {
    enable = true;
    openFirewall = true;
    downloadDir = downloadDir;
    configText = ''
      schedule2 = watch_directory,5,5,load.start=${downloadDir}/torrents
      schedule2 = untied_directory,5,5,stop_untied=
      schedule2 = tied_directory,5,5,start_tied=
    '';
  };

  services.flood = {
    enable = true;
    extraArgs = [
      "--allowedpath=${downloadDir}"
      "--rtsocket=${config.services.rtorrent.rpcSocket}"
      "--auth=none"
    ];
  };

  systemd.services.flood = {
    serviceConfig = {
      SupplementaryGroups = [ "rtorrent" ];
      ReadWritePaths = [ downloadDir ];
    };
  };
}
