{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (inputs.self.lib.mkKeys inputs.self "hunter")
    inputs.self.nixosModules.zram
  ];

  services.backup-local.subvols = [ "root" "var" ];
  services.backup-s3.subvols = [ "root" ];

  services.prometheus.exporters.smartctl = {
    devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" ];
    enable = true;
    port = 4002;
  };

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
      {
        directory = "/etc/vault";
        user = "root";
        group = "root";
        mode = "u=rwx,g=,o=";
      }
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

  environment.systemPackages = with pkgs; [
    ntfs3g
    fish
  ];

  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 3000 ];
  networking.firewall.allowedUDPPorts = [ ];
  networking.firewall.allowPing = true;

  fileSystems."/mnt/minio" = {
    device = "/dev/disk/by-uuid/795ba0eb-b8a5-4253-a8a4-bb703053ccb8";
    fsType = "btrfs";
    options = [
      "subvol=minio"
      "compress=zstd"
    ];
  };

  system = {
    autoUpgrade = {
      enable = false;
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
