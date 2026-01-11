terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.41"
    }
    shell = {
      source = "scottwinkler/shell"
      version = "~> 1.7.10"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

provider "shell" { }

resource "shell_script" "eval_store" {
  lifecycle_commands {
    create = <<EOF
      set -e

      build_dir="$(mktemp -d /tmp/eval_store_temp.XXXX)"
      nix copy --to "$build_dir" \
        "$(nix path-info --derivation \
          /home/hunter/config#nixosConfigurations.elderberry.config.system.build.toplevel)"
      cd "$build_dir"
      tar cz . > /tmp/do_eval_store.tar.gz
      cd -

      chmod +w "$build_dir" --recursive
      rm -rf "$build_dir"

      echo '{
        "path": "/tmp/do_eval_store.tar.gz"
      }'
    EOF
    delete = <<EOF
      rm /tmp/do_eval_store.tar.gz
      echo "{ }"
    EOF
    # read   = file("${path.module}/scripts/read.sh")
    # update = file("${path.module}/scripts/update.sh")
  }

  # lifecycle {
  #   replace_triggered_by = [
  #     self.lifecycle_commands
  #   ]
  # }
}

data "digitalocean_image" "nixos" {
  name = "NixOS"
}

resource "digitalocean_ssh_key" "hunter" {
  name       = "hunter"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMRFsB98uB4VjuBGAlfJx64Aclm6QHCaA0/dVUoLdn4M hunter@distortion\n"
}

resource "digitalocean_ssh_key" "ambrosia" {
  name       = "ambrosia"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIiiSLosPqVfFJUepkajqhuNSxn3+jjTNOGjyTpKzXKv hunter@ambrosia\n"
}

resource "digitalocean_ssh_key" "init" {
  name       = "init"
  public_key = file("./ssh/init.pub")
}

resource "digitalocean_droplet" "temp" {
  name               = "temp"
  backups            = "false"
  ipv6               = "true"
  monitoring         = "false"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  vpc_uuid           = "bbd52e78-d996-4e4d-ba82-cfb485053d62"
  image              = "ubuntu-24-04-x64"

  ssh_keys           = [
    digitalocean_ssh_key.init.id,
  ]

  user_data          = <<EOF
    #cloud-config

    runcmd:
      - |
        curl https://raw.githubusercontent.com/head-gardener/digitalocean-ext4-to-btrfs/master/ext2btrfs \
          | SSHD=1 INIT_OPTS="-x" CLOUD_CLEAR_SEMAPHORE=auto \
            bash -x || exit 0

        btrfs filesystem show /

        while [ ! -f "/tmp/store-ok" ]; do sleep 1; done
        mkdir /tmp/store
        tar xzf /tmp/store.tar.gz -C /tmp/store
        curl https://raw.githubusercontent.com/head-gardener/nixos-infect/master/nixos-infect \
          | PROVIDER=digitalocean NIXOS_FLAKE="github:head-gardener/config" \
            HOSTNAME="unnamed" EVAL_STORE="/tmp/store" NO_REBOOT="1" \
            bash -x

        btrfs filesystem label / nixos
        sync
        reboot -f

  EOF

  connection {
    type        = "ssh"
    host        = self.ipv4_address
    user        = "root"
    private_key = file("./ssh/init")
    timeout     = "5m"
  }

  # wait for btrfs converter to start
  provisioner "remote-exec" {
    inline = [
      "tail -n +1 -f /var/log/cloud-init-output.log || true",
    ]

    on_failure = continue
  }

  provisioner "file" {
    source = shell_script.eval_store.output["path"]
    destination = "/tmp/store.tar.gz"
  }

  provisioner "file" {
    content = ""
    destination = "/tmp/store-ok"
  }

  # wait for nixos-infect to finish
  provisioner "remote-exec" {
    inline = [
      "tail -n +1 -f /var/log/cloud-init-output.log || true",
    ]

    on_failure = continue
  }

  # wait for NixOS to boot
  provisioner "remote-exec" {
    inline = [
      "cat /proc/version | grep NixOS",
    ]

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "hunter"
      timeout     = "5m"
    }
  }
}

resource "digitalocean_droplet" "elderberry" {
  name               = "elderberry"
  backups            = "false"
  ipv6               = "true"
  monitoring         = "false"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  vpc_uuid           = "bbd52e78-d996-4e4d-ba82-cfb485053d62"
  image              = data.digitalocean_image.nixos.id

  ssh_keys           = [
    digitalocean_ssh_key.ambrosia.id,
    digitalocean_ssh_key.hunter.id,
  ]

  provisioner "local-exec" {
    command = <<EOF
      until ssh -o StrictHostKeyChecking=no root@${self.ipv4_address} true; do
        sleep 2
      done
      just update-role root@${self.ipv4_address} ${self.name}
      vault kv get -field=pub -mount=services ssh/${self.name} | ssh root@${self.ipv4_address} sh -c 'cat > /etc/ssh/ssh_host_ed25519_key.pub'
      vault kv get -field=priv -mount=services ssh/${self.name} | ssh root@${self.ipv4_address} sh -c 'cat > /etc/ssh/ssh_host_ed25519_key'
      vault kv put -mount=services hosts/${self.name} "address=${self.ipv4_address}"
      nixos-rebuild boot --target-host root@${self.ipv4_address} --flake github:head-gardener/config#${self.name}
      ssh root@${self.ipv4_address} reboot
    EOF
  }
}

output "ip" {
  value = digitalocean_droplet.temp.ipv4_address
}
