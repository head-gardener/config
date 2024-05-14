{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.blog.nixosModules.blog
    (inputs.self.lib.mkKeys inputs.self "hunter")
    "${inputs.self}/modules/backup-s3.nix"
    "${inputs.self}/modules/backup-local.nix"
    "${inputs.self}/modules/grafana.nix"
    "${inputs.self}/modules/nginx.nix"
    "${inputs.self}/modules/hydra.nix"
    "${inputs.self}/modules/refresher-staging.nix"
    "${inputs.self}/modules/refresher-config.nix"
    "${inputs.self}/modules/prometheus.nix"
    "${inputs.self}/modules/prometheus-node.nix"
    "${inputs.self}/modules/zram.nix"
  ];

  services.backup-local.subvols = [ "var" ];
  services.backup-s3.subvols = [ "root" "var" ];

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.efi = {
    canTouchEfiVariables = true;
  };
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount ${config.fileSystems."/".device} /btrfs_tmp
    if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
    fi

    delete_subvolume_recursively() {
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
            delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
    }

    for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
        delete_subvolume_recursively "$i"
    done

    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/ssh"
    ];
    users.hunter = {
      directories = [
        ".local/share/fish"
        ".local/share/kitty-ssh-kitten"
        ".terminfo"
      ];
    };
    files = [ ];
  };

  fileSystems."/etc/ssh" = {
    depends = [ "/persist" ];
    neededForBoot = true;
  };

  networking.networkmanager.enable = false;

  services.auspex = {
    enable = true;
    openFirewall = true;
    port = 8090;
  };

  environment.systemPackages = with pkgs; [
    ntfs3g
    fish
  ];

  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;

  system = {
    autoUpgrade = {
      enable = true;
      allowReboot = true;
      dates = "hourly";
      flake = "github:head-gardener/config";
      flags = [ ];
    };
  };

  programs = {
    atop = {
      enable = true;
      atopService.enable = true;
      atopRotateTimer.enable = true;
      netatop.enable = true;
      settings = {
        interval = 5;
        flags = "1fA";
      };
    };
  };
}
