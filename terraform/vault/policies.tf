resource "vault_policy" "terraform" {
  name = "terraform"

  policy = <<EOT
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "patch", "sudo"]
}
  EOT
}

locals {
  services = [
    "jenkins",
    "nix-serve",
    "sing-box",
  ]
  externals = [
    "github",
    "digitalocean",
  ]
  buckets = [
    "admin",
    "backup",
    "torrent",
  ]
  repos = [
    "config",
  ]
  gpg-keys = [
    "ambrosia",
    "blueberry",
  ]
}

resource "vault_policy" "gpg_key_user" {
  for_each = toset(local.gpg-keys)
  name = "gpg-key-${each.value}"

  policy = <<EOT
path "services/data/gpg/${each.value}" {
  capabilities = ["read"]
}
  EOT
}

resource "vault_policy" "service_rotate" {
  for_each = toset(local.services)
  name = "rotate-${each.value}"

  policy = <<EOT
path "services/data/${each.value}/*" {
  capabilities = ["update"]
}
  EOT
}

resource "vault_policy" "service_user" {
  for_each = toset(local.services)
  name = "service-${each.value}"

  policy = <<EOT
path "services/data/${each.value}/*" {
  capabilities = ["read"]
}
  EOT
}

resource "vault_policy" "bucket_user" {
  for_each = toset(local.buckets)
  name = "bucket-${each.value}"

  policy = <<EOT
path "services/data/minio/${each.value}" {
  capabilities = ["read"]
}
  EOT
}

resource "vault_policy" "repo_user" {
  for_each = toset(local.repos)
  name = "repo-${each.value}"

  policy = <<EOT
path "externals/data/github/repo/${each.value}" {
  capabilities = ["read"]
}
  EOT
}

resource "vault_policy" "externals_user" {
  for_each = toset(local.externals)
  name = "external-${each.value}"

  policy = <<EOT
path "externals/data/${each.value}/*" {
  capabilities = ["read"]
}
  EOT
}
