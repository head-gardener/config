resource "vault_auth_backend" "approle" {
  type = "approle"
}

locals {
  machines = {
    elderberry = [ vault_policy.service_user["sing-box"].name ]
    ambrosia = [
      vault_policy.service_user["sing-box"].name,
      vault_policy.externals_user["github"].name
    ]
  }

  service = {
    terraform = [ vault_policy.terraform.name ]
  }
}

# service

resource "vault_approle_auth_backend_role" service {
  for_each        = local.service
  backend         = vault_auth_backend.approle.path
  role_name       = each.key
  token_policies  = each.value
  token_ttl       = 3600
  token_type      = "service"
}

resource "vault_approle_auth_backend_role_secret_id" service {
  for_each  = local.service
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.service[each.key].role_name
}

output "service_role_id" {
  value = {
    for k, v in local.service : k => vault_approle_auth_backend_role.service[k].role_id
  }
}

output "service_secret_id" {
  value = {
    for k, v in local.service : k => vault_approle_auth_backend_role_secret_id.service[k].secret_id
  }
  sensitive = true
}

# machines

resource "vault_approle_auth_backend_role" machine {
  for_each        = local.machines
  backend         = vault_auth_backend.approle.path
  role_name       = each.key
  token_policies  = each.value
  token_ttl       = 3600
  token_type      = "batch"
}

resource "vault_approle_auth_backend_role_secret_id" machine {
  for_each  = local.machines
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.machine[each.key].role_name
}

output "machine_role_id" {
  value = {
    for k, v in local.machines : k => vault_approle_auth_backend_role.machine[k].role_id
  }
}

output "machine_secret_id" {
  value = {
    for k, v in local.machines : k => vault_approle_auth_backend_role_secret_id.machine[k].secret_id
  }
  sensitive = true
}
