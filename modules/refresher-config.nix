{ inputs, config, ... }: {
  imports = [ inputs.agenix.nixosModules.default ];

  age.secrets.id_conf = {
    file = "${inputs.self}/secrets/id_conf.age";
    owner = "refresher-config";
    group = "refresher-config";
  };

  services.refresher = {
    enable = true;
    suffix = "config";
    inputs = [ "notes" ];
    repo = "git@github.com:head-gardener/config";
    identity = config.age.secrets.id_conf.path;
  };
}