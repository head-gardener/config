{ alloy, lib, config, ... }: {
  options.services.minio.port = lib.mkOption { type = lib.types.port; };
  options.services.minio.consolePort = lib.mkOption { type = lib.types.port; };

  config = {
    personal.va.templates.minio-admin = {
      contents = ''
        {{ with secret "services/minio/admin" }}
        MINIO_ROOT_USER={{ .Data.data.user }}
        MINIO_ROOT_PASSWORD={{ .Data.data.pass }}
        {{ end }}
      '';
      owner = "minio";
      group = "minio";
      for = "minio.service";
    };

    personal.mappings."minio.local".nginx = {
      enable = true;
      port = config.services.minio.port;
    };

    personal.mappings."minio-console.local".nginx = {
      enable = true;
      port = config.services.minio.consolePort;
    };

    services.minio = {
      enable = true;
      dataDir = [ "/mnt/minio" ];
      rootCredentialsFile =
        config.personal.va.templates.minio-admin.destination;
      port = 9000;
      consolePort = 9001;
    };

    networking.firewall.allowedTCPPorts = lib.mkMerge [
      (lib.mkIf (alloy.minio.address != alloy.nginx.address)
        [ config.services.minio.port ])
      [ config.services.minio.consolePort ]
    ];
  };
}
