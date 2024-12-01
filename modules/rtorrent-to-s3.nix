{ inputs, lib, config, ... }:
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

  systemd.services.rtorrent.after = [ "mnt_s3-torrent.mount" ];
  systemd.services.flood.after = [ "rtorrent.service" ];

  services.rtorrent = {
    enable = true;
    openFirewall = true;
    downloadDir = downloadDir;
    configText = let cfg = config.services.rtorrent;
    in lib.mkForce ''
      # Instance layout (base paths)
      method.insert = cfg.basedir, private|const|string, (cat,"${cfg.dataDir}/")
      method.insert = cfg.watch,   private|const|string, (cat,"${downloadDir}/","torrents/")
      method.insert = cfg.logfile, private|const|string, (cat,(cfg.basedir),"execute.log")
      method.insert = cfg.rpcsock, private|const|string, (cat,"${cfg.rpcSocket}")

      # Create instance directories
      execute.throw = sh, -c, (cat, "mkdir -p ", (cfg.basedir), "/session ", (cfg.watch))

      # Listening port for incoming peer traffic (fixed; you can also randomize it)
      network.port_range.set = ${toString cfg.port}-${toString cfg.port}
      network.port_random.set = no

      # Tracker-less torrent and UDP tracker support
      # (conservative settings for 'private' trackers, change for 'public')
      dht.mode.set = disable
      protocol.pex.set = no
      trackers.use_udp.set = no

      # Peer settings
      throttle.max_uploads.set = 100
      throttle.max_uploads.global.set = 250

      throttle.min_peers.normal.set = 20
      throttle.max_peers.normal.set = 60
      throttle.min_peers.seed.set = 30
      throttle.max_peers.seed.set = 80
      trackers.numwant.set = 80

      protocol.encryption.set = allow_incoming,try_outgoing,enable_retry

      # Limits for file handle resources, this is optimized for
      # an `ulimit` of 1024 (a common default). You MUST leave
      # a ceiling of handles reserved for rTorrent's internal needs!
      network.http.max_open.set = 50
      network.max_open_files.set = 600
      network.max_open_sockets.set = 3000

      # Memory resource usage (increase if you have a large number of items loaded,
      # and/or the available resources to spend)
      pieces.memory.max.set = 1800M
      network.xmlrpc.size_limit.set = 4M

      # Basic operational settings (no need to change these)
      session.path.set = (cat, (cfg.basedir), "session/")
      print = (cat, "pid is ", (system.pid))
      directory.default.set = "${cfg.downloadDir}"
      log.execute = (cfg.logfile)
      # log.xmlrpc = "/proc/self/fd/1"
      execute.nothrow = sh, -c, (cat, "echo >", (session.path), "rtorrent.pid", " ", (system.pid))

      # Other operational settings (check & adapt)
      encoding.add = utf8
      system.umask.set = 0027
      system.cwd.set = (cfg.basedir)
      network.http.dns_cache_timeout.set = 25
      schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

      # Watch directories (add more as you like, but use unique schedule names)
      schedule2 = watch_start, 10, 10, ((load.start, (cat, (cfg.watch), "*.torrent")))
      # schedule2 = watch_load, 11, 10, ((load.normal, (cat, (cfg.watch), "load/*.torrent")))

      # Logging:
      #   Levels = critical error warn notice info debug
      #   Groups = connection_* dht_* peer_* rpc_* storage_* thread_* tracker_* torrent_*
      log.open_file = "log", (cfg.logfile)
      log.add_output = "info", "log"
      ##log.add_output = "tracker_debug", "log"

      # XMLRPC
      scgi_local = (cfg.rpcsock)
      # WARN: this is a kernel panic!
      # schedule = scgi_group,0,0,"execute.nothrow=chown,\":${cfg.group}\",(cfg.rpcsock)"
      schedule = scgi_permission,0,0,"execute.nothrow=chmod,\"g+w,o=\",(cfg.rpcsock)"
    '';
  };

  services.flood = {
    enable = true;
    host = "::";
    port = 3001;
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
