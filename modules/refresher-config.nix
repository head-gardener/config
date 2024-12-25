{ config, ... }: {
  services.refresher.config = {
    inputs = [ "notes" ];
    repo = "git@github.com:head-gardener/config";
    identity = config.personal.va.templates.id_conf.destination;
  };
}
