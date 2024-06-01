{ pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    8443 # dashboard
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [
    # "--kubelet-arg=v=4" # Optionally add additional args to k3s
  ];
  environment.systemPackages = [ pkgs.k3s ];

  services.btrbk.instances.k3s = {
    onCalendar = "*:0/10:00";
    settings = {
      snapshot_create = "ondemand";
      snapshot_dir = "snapshots";
      snapshot_preserve = "no";
      snapshot_preserve_min = "latest";
      target = "/mnt/btr_backup/k3s";
      target_preserve = "5d";
      target_preserve_min = "1d";
      incremental = "no";
      volume = {
        "/mnt/btr_pool" = {
          subvolume = "var/lib/rancher/k3s/storage";
        };
      };
    };
  };
}
