{ inputs, config, ... }: {
  age.secrets.minio-creds = {
    file = "${inputs.self}/secrets/minio-creds.age";
    owner = "minio";
    group = "minio";
  };

  services.minio = {
    enable = true;
    rootCredentialsFile = config.age.secrets.minio-creds.path;
  };

  networking.firewall.allowedTCPPorts = [ 9000 9001 ];
}
