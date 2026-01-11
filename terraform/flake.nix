{
  inputs = {
    parent.url = "git+file:..";
  };

  outputs =
    inputs:
    with inputs;
    parent.inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      perSystem =
        { inputs', ... }:
        {
          packages = {
            digitaloceanUbuntu = inputs'.parent.packages.cloud-vm.override {
              imgHash = "sha256-uVLOFcwDNdoNBVP2pJLvhJdE7kp5OV5FiHSUHLhTa9M=";
              imgSize = "25G";
              extraUserData = ''
                runcmd:
                  - |
                    set -e
                    mount -t 9p host1 /mnt1 --mkdir
                    mount -t 9p host2 /mnt2 --mkdir
                    mount -t 9p host3 /mnt3 --mkdir
                    SSHD=1 INIT_OPTS="-x" CLOUD_CLEAR_SEMAPHORE=auto TMPFS_BALANCE=1 \
                      /mnt1/ext2btrfs -x || exit 0
                    btrfs filesystem show /
                    mkdir /tmp/store
                    tar xzf /mnt2/eval_store.tar.gz -C /tmp/store
                    cat /mnt3/nixos-infect \
                      | PROVIDER=digitalocean NIXOS_FLAKE="github:head-gardener/config" \
                        HOSTNAME="elderberry" EVAL_STORE="/tmp/store" NO_REBOOT="1" \
                        bash -x
                    btrfs filesystem label / nixos
                    sync
                    reboot -f
                ssh_authorized_keys:
                  - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiiSLosPqVfFJUepkajqhuNSxn3+jjTNOGjyTpKzXKv hunter@ambrosia"
              '';
            };
          };
        };
    };
}
