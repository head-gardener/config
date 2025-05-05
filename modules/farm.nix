{ pkgs, ... }: {
  personal.term-farm = {
    enable = true;
    net = {
      subnet_byte = 72;
      uuid = "44913701-24ed-4786-af33-bdf04dff6272";
      bridge_name = "virbr0";
    };
    pool = {
      uuid = "aac75772-e04c-4e5a-8565-5e825fcff888";
      path = "/var/lib/libvirt/pools/farm";
    };
    machines = {
      playground = {
        uuid = "cd715eb3-8a0c-40dd-bd5b-5236a1dea1c1";
        resources = {
          memory = {
            count = 8;
            unit = "GiB";
          };
        };
        src = pkgs.fetchurl {
          url =
            "https://get.debian.org/images/cloud/bookworm/20250428-2096/debian-12-generic-amd64-20250428-2096.qcow2";
          hash = "sha256-tvaiiW88LKOr39f0rB2pkqojB7vUSYTK9DeEK/CBAO0=";
        };
        net = {
          mac = "52:54:00:6c:2e:a9";
          ip_byte = 13;
        };
        forward = [{
          from = 10022;
          to = 22;
        }];
        cloud-config = {
          user-data = {
            users = [{ name = "root"; }];
            disable_root = false;
            package_update = true;
            package_upgrade = true;
            ssh_authorized_keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiiSLosPqVfFJUepkajqhuNSxn3+jjTNOGjyTpKzXKv hunter@ambrosia"
            ];
          };
        };
      };
    };
  };
}
