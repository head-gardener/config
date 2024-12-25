{ inputs, config, pkgs, ... }:
let downloadDir = "/mnt/s3_torrent";
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

  systemd.services.deluged.after = [ "mnt_s3-torrent.mount" ];

  services.deluge = {
    enable = true;
    declarative = true;
    authFile = pkgs.writeText "deluge-auth" "amdin:password:10";
    config = {
      torrentfiles_location = "${downloadDir}/torrents";
      download_location = "${downloadDir}/downloads";
      copy_torrent_file = true;
      move_completed = true;
      move_completed_path = "/srv/torrents";
    };
    web = {
      enable = true;
      port = 3001;
      openFirewall = true;
    };
  };
}
