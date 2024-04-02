{ inputs, config, ... }: {
  age.secrets.id_conf = {
    file = "${inputs.self}/secrets/id_conf.age";
  };

  services.refresher.config = {
    inputs = [ "notes" ];
    repo = "git@github.com:head-gardener/config";
    identity = config.age.secrets.id_conf.path;
  };
}
