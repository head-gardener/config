{ alloy, lib, inputs, config, ... }: {
  age.secrets.minio-creds = {
    file = "${inputs.self}/secrets/minio-creds.age";
    owner = "minio";
    group = "minio";
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = config.age.secrets.minio-creds.path;
  };

  networking.firewall.allowedTCPPorts = lib.mkMerge [
    (lib.mkIf (alloy.minio.host != alloy.nginx.host) [ 9000 ])
    [ 9001 ]
  ];
}
