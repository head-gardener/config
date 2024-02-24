{ inputs, config, ... }: {
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets.id_conf = {
    file = "${inputs.self}/secrets/id_conf.age";
    owner = "refresher-staging";
    group = "refresher-staging";
  };

  services.refresher = {
    enable = true;
    suffix = "staging";
    staging = true;
    repo = "git@github.com:head-gardener/config";
    identity = config.age.secrets.id_conf.path;
  };
}
