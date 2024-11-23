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
      vault-agent
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
      rotate-all
      transmission-to-s3
      vault
      wireguard-server
    ] ++ server;
    cherry = [
      cache
    ];
    elderberry = [
      cache
      sing-box-out
      wireguard-client
    ] ++ server;
  };
}
