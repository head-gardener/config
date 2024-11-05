{ net, pkgs, config, ... }: {
  nixpkgs.allowUnfreeByName = [ "vault" ];

  environment.systemPackages = [ pkgs.vault ];

  systemd.services.vault.after = [ config.personal.wg.service ];

  services.vault = {
    enable = true;
    address = "${net.self.ipv4}:8200";
    storageBackend = "raft";
    storageConfig = ''
      node_id = "node1"
    '';
    extraConfig = ''
      api_addr = "http://${net.self.ipv4}:8200"
      cluster_addr = "https://${net.self.ipv4}:8201"
    '';
  };
}
