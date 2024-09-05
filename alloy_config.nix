{ alloy-utils, ... }:
{
  settings = {
    resolve = alloy-utils.fromTable {
      blueberry = "192.168.1.102";
      cherry = "192.168.1.195";
      elderberry = "157.230.20.233";
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
    xray-in-public = import ./modules/xray-in.nix { public = true; };
    xray-in-private = import ./modules/xray-in.nix { public = false; };
    xray-out = ./modules/xray-out.nix;
  };

  hosts = mods: with mods; {
    distortion = [ cache ];
    shears = [ cache ];
    ambrosia = [ cache xray-in-private ];
    apple = [ cache ];
    blueberry = [
      grafana
      hydra
      minio
      nginx
      nix-serve
      refresher-config
      refresher-staging
      xray-in-public
    ];
    cherry = [
      cache
    ];
    elderberry = [
      cache
      xray-out
    ];
  };
}
