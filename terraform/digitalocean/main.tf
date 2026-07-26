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

resource "digitalocean_ssh_key" "hunter" {
  name       = "hunter"
  public_key = join("", [
    for f in fileset(path.root, "../../ssh/hunter/*") : file(f)
  ])
}

resource "digitalocean_droplet" "elderberry" {
  name               = "elderberry"
  backups            = "false"
  ipv6               = "false"
  monitoring         = "false"
  region             = "fra1"
  size               = "s-1vcpu-1gb"
  vpc_uuid           = "bbd52e78-d996-4e4d-ba82-cfb485053d62"
  image              = "ubuntu-24-04-x64"

  ssh_keys           = [
    digitalocean_ssh_key.hunter.id,
  ]
}

# resource "digitalocean_droplet" "elderberry-leg" {
#   provisioner "local-exec" {
#     command = <<EOF
#       until ssh -o StrictHostKeyChecking=no root@${self.ipv4_address} true; do
#         sleep 2
#       done
#       just update-role root@${self.ipv4_address} ${self.name}
#       vault kv get -field=pub -mount=services ssh/${self.name} | ssh root@${self.ipv4_address} sh -c 'cat > /etc/ssh/ssh_host_ed25519_key.pub'
#       vault kv get -field=priv -mount=services ssh/${self.name} | ssh root@${self.ipv4_address} sh -c 'cat > /etc/ssh/ssh_host_ed25519_key'
#       vault kv put -mount=services hosts/${self.name} "address=${self.ipv4_address}"
#       nixos-rebuild boot --target-host root@${self.ipv4_address} --flake github:head-gardener/config#${self.name}
#       ssh root@${self.ipv4_address} reboot
#     EOF
#   }
# }

output "ip" {
  value = digitalocean_droplet.elderberry.ipv4_address
}
