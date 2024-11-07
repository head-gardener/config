resource "vault_policy" "terraform" {
  name = "terraform"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}
  EOT
}

locals {
  services = [ "sing-box" ]
}

resource "vault_policy" "service_user" {
  for_each = toset(local.services)
  name = each.value

  policy = <<EOT
path "services/data/${each.value}/*" {
  capabilities = ["read"]
}
  EOT
}
