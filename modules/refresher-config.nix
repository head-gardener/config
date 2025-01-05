{ config, ... }: {
  # personal.va.templates.id_conf = {
  #   contents = ''
  #     -----BEGIN OPENSSH PRIVATE KEY-----
  #     {{ with secret "externals/github/repo/config" }}{{ .Data.data.key }}{{ end }}
  #     -----END OPENSSH PRIVATE KEY-----
  #   '';
  # };

  services.refresher.config = {
    inputs = [ "notes" ];
    repo = "git@github.com:head-gardener/config";
    identity = config.personal.va.templates.id_conf.destination;
  };
}
