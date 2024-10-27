{ alloy-utils, ... }:

let
  mainUser = "hunter";

  allowFor = user: {
    users.users.${mainUser}.openssh.authorizedKeys.keyFiles = [ ./ssh/${mainUser}/${user} ];
  };
in {
  settings = {
    resolve = alloy-utils.fromTable {
      blueberry = "192.168.1.102";
      cherry = "192.168.1.195";
      elderberry = "157.230.20.233";
    };
  };

  modules = {
    backup-local = ./modules/backup-local.nix;
    backup-s3 = ./modules/backup-s3.nix;
    cache = ./modules/alloy/cache.nix;
    grafana = ./modules/alloy/grafana.nix;
    hydra = ./modules/alloy/hydra.nix;
    jenkins-mono = ./modules/jenkins/jenkins-mono.nix;
    minio = ./modules/alloy/minio.nix;
    nginx = ./modules/alloy/nginx.nix;
    nix-serve = ./modules/alloy/nix-serve.nix;
    prometheus = ./modules/alloy/prometheus.nix;
    prometheus-node = ./modules/alloy/prometheus-node.nix;
    refresher-config = ./modules/refresher-config.nix;
    refresher-staging = ./modules/refresher-staging.nix;
    sing-box = ./modules/alloy/sing-box.nix;
    sing-box-out = ./modules/sing-box-out.nix;
    wireguard-server = {
      imports = [ ./modules/wireguard.nix ];
      services.wg.isClient = false;
    };
    wireguard-client = {
      imports = [ ./modules/wireguard.nix ];
      services.wg.isClient = true;
    };
  };

  hosts = mods: with mods; {
    distortion = [
      (allowFor "tackle")
      cache
      sing-box
    ];
    shears = [
      cache
    ];
    ambrosia = [
      cache
      sing-box
      wireguard-client
    ];
    apple = [
      cache
    ];
    blueberry = [
      backup-local
      backup-s3
      cache
      grafana
      jenkins-mono
      minio
      nginx
      nix-serve
      prometheus
      prometheus-node
      refresher-staging
      wireguard-server
    ];
    cherry = [
      backup-local
      backup-s3
      cache
      prometheus-node
    ];
    elderberry = [
      cache
      sing-box-out
      wireguard-client
    ];
  };
}
