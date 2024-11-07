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
  externals = [ "github" ]
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

resource "vault_policy" "externals_user" {
  for_each = toset(local.externals)
  name = each.value

  policy = <<EOT
path "externals/data/${each.value}/*" {
  capabilities = ["read"]
}
  EOT
}
