terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.41"
    }
  }
}

variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
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

resource "digitalocean_droplet" "elderberry" {
  backups            = "false"
  ipv6               = "false"
  monitoring         = "false"
  name               = "elderberry"
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
  value = digitalocean_droplet.elderberry.ipv4_address
}
