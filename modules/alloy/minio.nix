{ alloy, lib, inputs, config, ... }: {
  options.services.minio.port = lib.mkOption { type = lib.types.port; };
  options.services.minio.consolePort = lib.mkOption { type = lib.types.port; };

  config = {
    age.secrets.minio-creds = {
      file = "${inputs.self}/secrets/minio-creds.age";
      owner = "minio";
      group = "minio";
    };

    systemd.services.minio.restartTriggers = [ "${config.age.secrets.minio-creds.file}" ];

    services.minio = {
      enable = true;
      rootCredentialsFile = config.age.secrets.minio-creds.path;
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
