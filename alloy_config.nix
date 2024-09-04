{ alloy-utils, ... }:
{
  settings = {
    resolve = alloy-utils.fromTable {
      blueberry = "192.168.1.102";
      cherry = "192.168.1.195";
    };
  };

  modules = {
    cache = ./modules/alloy/cache.nix;
    grafana = ./modules/alloy/grafana.nix;
    hydra = ./modules/alloy/hydra.nix;
    minio = ./modules/alloy/minio.nix;
    nginx = ./modules/alloy/nginx.nix;
    nix-serve = ./modules/alloy/nix-serve.nix;
    refresher-config = ./modules/refresher-config.nix;
    refresher-staging = ./modules/refresher-staging.nix;
  };

  hosts = mods: with mods; {
    distortion = [ cache ];
    shears = [ cache ];
    ambrosia = [ cache ];
    apple = [ cache ];
    blueberry = [
      nginx
      hydra
      grafana
      nix-serve
      refresher-config
      refresher-staging
    ];
    cherry = [
      cache
      minio
    ];
  };
}
