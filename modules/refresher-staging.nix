{ inputs, config, ... }: {
  age.secrets.id_conf-staging = {
    file = "${inputs.self}/secrets/id_conf.age";
    owner = "refresher-staging";
    group = "refresher-staging";
  };

  services.refresher.staging = {
    staging = true;
    onCalendar = "weekly";
    repo = "git@github.com:head-gardener/config";
    identity = config.age.secrets.id_conf-staging.path;
  };
}
