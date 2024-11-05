{ alloy-utils, self, ... }:

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

  modules = self.nixosModules // {
    wireguard-server = {
      imports = [ ./modules/wireguard.nix ];
      personal.wg.isClient = false;
    };
    wireguard-client = {
      imports = [ ./modules/wireguard.nix ];
      personal.wg.isClient = true;
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
      tailscale-client
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
      loki
      minio
      nats
      nginx
      nix-serve
      prometheus
      prometheus-node
      promtail
      refresher-staging
      tuner
      vault
      wireguard-server
    ];
    cherry = [
      backup-local
      backup-s3
      cache
      prometheus-node
      promtail
    ];
    elderberry = [
      cache
      prometheus-node
      promtail
      sing-box-out
      tuner
      wireguard-client
    ];
  };
}
