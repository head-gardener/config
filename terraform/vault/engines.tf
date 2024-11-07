resource "vault_mount" "services" {
  path        = "services"
  type        = "kv"
  options     = { version = "2" }
  description = "secrets used by internal services"
}

resource "vault_kv_secret_backend_v2" "services" {
  mount                = vault_mount.services.path
  max_versions         = 5
  cas_required         = false
}
