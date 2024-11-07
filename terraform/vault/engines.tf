resource "vault_mount" "services" {
  max_lease_ttl_seconds     = 604800
  default_lease_ttl_seconds = 3600
  path                      = "services"
  type                      = "kv"
  options                   = { version = "2" }
  description               = "secrets used by internal services"
}

resource "vault_kv_secret_backend_v2" "services" {
  mount                = vault_mount.services.path
  max_versions         = 5
  cas_required         = false
}

resource "vault_mount" "externals" {
  max_lease_ttl_seconds     = 604800
  default_lease_ttl_seconds = 3600
  path                      = "externals"
  type                      = "kv"
  options                   = { version = "2" }
  description               = "external service secrets"
}

resource "vault_kv_secret_backend_v2" "externals" {
  mount                = vault_mount.services.path
  max_versions         = 5
  cas_required         = false
}
