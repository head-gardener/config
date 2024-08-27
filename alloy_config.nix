{ alloy-utils, ... }:
{
  settings = {
    resolve = alloy-utils.fromTable {
      blueberry = "192.168.1.102";
    };
  };

  modules = {
    cache = ./modules/alloy/cache.nix;
    refresher-staging = ./modules/refresher-staging.nix;
    refresher-config = ./modules/refresher-config.nix;
    nginx = ./modules/alloy/nginx.nix;
    nix-serve = ./modules/alloy/nix-serve.nix;
    hydra = ./modules/alloy/hydra.nix;
    grafana = ./modules/alloy/grafana.nix;
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
    cherry = [ cache ];
  };
}
