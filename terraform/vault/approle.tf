resource "vault_auth_backend" "approle" {
  type = "approle"
}

locals {
  machines = {
    elderberry = [ vault_policy.service_user["sing-box"].name ]
    ambrosia = [ vault_policy.service_user["sing-box"].name ]
  }
}

resource "vault_approle_auth_backend_role" machine {
  for_each        = local.machines
  backend         = vault_auth_backend.approle.path
  role_name       = each.key
  token_policies  = each.value
  token_ttl       = 300
  token_type      = "batch"
}

resource "vault_approle_auth_backend_role_secret_id" machine {
  for_each  = local.machines
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.machine[each.key].role_name
}

output "role_id" {
  value = {
    for k, v in local.machines : k => vault_approle_auth_backend_role.machine[k].role_id
  }
}

output "secret_id" {
  value = {
    for k, v in local.machines : k => vault_approle_auth_backend_role_secret_id.machine[k].secret_id
  }
  sensitive = true
}
