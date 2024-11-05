locals {
  services = [ "sing-box" ]
}

resource "vault_policy" "kv_admin" {
  name = "kv_admin"

  policy = <<EOT
path "services/*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch"]
}
  EOT
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
