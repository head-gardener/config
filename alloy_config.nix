{ alloy-utils, self, ... }:

let
  mainUser = "hunter";

  allowFor = user: {
    users.users.${mainUser}.openssh.authorizedKeys.keyFiles = [ ./ssh/${mainUser}/${user} ];
  };

  strictSSH = {
    services.fail2ban.jails = {
      sshd = {
        settings = {
          findtime = "96h";
          maxretries = 2;
        };
      };
    };
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
      pass
      podman
      sing-box
      tailscale-client
      terraform
      vagrant
      vault-agent
      wireguard-client
    ];
    apple = [
      cache
    ];
    blueberry = [
      backup-local
      backup-s3
      blog
      cache
      gitea
      grafana
      jenkins-mono
      loki
      minio
      nats
      nginx
      nix-serve
      prometheus
      refresher-config
      refresher-staging
      rotate-all
      rtorrent-to-s3
      vault
      wireguard-server
    ] ++ server;
    cherry = [
      cache
    ];
    elderberry = [
      cache
      fail2ban
      sing-box-out
      strictSSH
      wireguard-client
    ] ++ server;
  };
}
