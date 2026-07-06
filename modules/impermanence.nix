{
  config,
  inputs,
  utils,
  ...
}:

# migrate this to /persist
{
  personal.checks.impermanence = {
    modules = [
      inputs.self.nixosModules.impermanence
      (
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          environment.systemPackages = [ pkgs.btrfs-progs ];
          services.openssh.enable = lib.mkForce false;

          boot.initrd.systemd.extraBin = {
            btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
            grep = "${pkgs.gnugrep}/bin/grep";
          };

          # this is SLOP
          virtualisation.fileSystems."/" = {
            options = [ "subvol=root" ];
          };

          virtualisation.fileSystems."/persistent" = {
            device = config.fileSystems."/".device;
            neededForBoot = true;
            fsType = "btrfs";
            options = [ "subvol=persistent" ];
          };

          boot.initrd.systemd.services."btrfs-subvols" =
            let
              root = config.fileSystems."/".device;
            in
            {
              unitConfig.DefaultDependencies = false;
              serviceConfig.Type = "oneshot";
              requiredBy = [ "initrd.target" ];
              before = [ "wipe-file-systems.service" ];

              requires = [
                "${utils.escapeSystemdPath root}.device"
                "modprobe@btrfs.service"
              ];
              after = [
                "${utils.escapeSystemdPath root}.device"
                "local-fs-pre.target"
                "systemd-makefs@${utils.escapeSystemdPath root}.service"
                "modprobe@btrfs.service"
              ];

              script = ''
                set -x

                udevadm settle
                mount /dev/vda /mnt --mkdir
                btrfs subvolume list /mnt | grep persistent && exit 0
                btrfs subvolume create /mnt/root
                btrfs subvolume create /mnt/persistent
                btrfs subvolume create /mnt/old_roots
                umount /mnt
              '';
            };
        }
      )
    ];
    script = ''
      machine.wait_for_unit("multi-user.target")
      machine.succeed(
          "echo 'stale-data' > /will-be-wiped && "
          "btrfs subvolume create /dead-subvol && "
          "touch /dead-subvol/nested-file &&"
          "touch /etc/ssh/persistent"
      )
      machine.succeed("test -f /persistent/etc/ssh/persistent")

      # check rotation on reboot
      machine.shutdown()
      machine.start()
      machine.wait_for_unit("multi-user.target")
      machine.fail("test -f /will-be-wiped")
      machine.fail("test -d /dead-subvol")
      machine.succeed("test -f /etc/ssh/persistent")

      def mount_top():
        machine.succeed(
            "mkdir /tmp/top && "
            "mount -o subvolid=5 /dev/vda /tmp/top"
        )
        entries = machine.succeed("ls /tmp/top/old_roots").strip().split()
        assert len(entries) > 0, "no old_roots entries!"
        # ls is alpabetical, newest date is always last
        return entries

      roots = mount_top()
      old_root = roots[-1]
      machine.succeed(f"test -f /tmp/top/old_roots/{old_root}/will-be-wiped")
      machine.succeed(f"test -f /tmp/top/old_roots/{old_root}/dead-subvol/nested-file")
      machine.succeed(f"touch -m -d '31 days ago' /tmp/top/old_roots/{old_root}")

      # check cleanup
      machine.shutdown()
      machine.start()
      machine.wait_for_unit("multi-user.target")
      mount_top()
      machine.fail(f"test -d /tmp/top/old_roots/{old_root}")
    '';
  };

  boot.initrd.systemd = {
    services.wipe-file-systems = {
      unitConfig.DefaultDependencies = false;
      serviceConfig.Type = "oneshot";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];

      requires = [ "${utils.escapeSystemdPath config.fileSystems."/".device}.device" ];
      after = [
        "${utils.escapeSystemdPath config.fileSystems."/".device}.device"
        "local-fs-pre.target"
        "systemd-makefs@${utils.escapeSystemdPath config.fileSystems."/".device}.service"
      ];

      script = ''
        set -x

        mkdir /btrfs_tmp
        mount '${config.fileSystems."/".device}' /btrfs_tmp
        if [[ -e /btrfs_tmp/root ]]; then
          mkdir -p /btrfs_tmp/old_roots
          timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
          mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        fi

        for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          btrfs subvolume delete --recursive "$i"
        done

        btrfs subvolume create /btrfs_tmp/root
        umount /btrfs_tmp
      '';
    };
  };

  environment.persistence."/persistent" = {
    hideMounts = true;
    directories = [
      "/etc/ssh"
      # TODO: check if var is on separate vol, add here if not
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

  age.identityPaths = [
    "/persistent/etc/ssh/ssh_host_ed25519_key"
  ];
}
