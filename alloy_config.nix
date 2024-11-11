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

  hosts = mods: with mods; let
    server = [
      ansible-node
      prometheus-node
      promtail
      tuner
    ];
  in {
    distortion = [
      (allowFor "tackle")
      cache
      sing-box
      terraform
      vault-agent
      wireguard-client
    ];
    shears = [
      cache
    ];
    ambrosia = [
      cache
      docker
      sing-box
      tailscale-client
      terraform
      vault-agent
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
      loki
      minio
      nats
      nginx
      nix-serve
      prometheus
      refresher-staging
      vault
      wireguard-server
    ] ++ server;
    cherry = [
      backup-local
      backup-s3
      cache
    ];
    elderberry = [
      cache
      sing-box-out
      vault-agent
      wireguard-client
    ] ++ server;
  };
}
