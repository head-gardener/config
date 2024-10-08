{ alloy-utils, ... }:
let
  mainUser = "hunter";

  allowFor = user: {
    users.users.${mainUser}.openssh.authorizedKeys.keyFiles = [ ./ssh/${mainUser}/${user} ];
  };
in
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
    sing-box = ./modules/alloy/sing-box.nix;
    xray-out = ./modules/xray-out.nix;
  };

  hosts = mods: with mods; {
    distortion = [
      cache
      sing-box
      (allowFor "tackle")
    ];
    shears = [ cache ];
    ambrosia = [
      cache
      sing-box
    ];
    apple = [ cache ];
    blueberry = [
      cache
      grafana
      hydra
      minio
      nginx
      nix-serve
      refresher-config
      refresher-staging
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
