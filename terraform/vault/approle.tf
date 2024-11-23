resource "vault_auth_backend" "approle" {
  type = "approle"
}

locals {
  machine = {
    blueberry = [
      vault_policy.bucket_user["admin"].name,
      vault_policy.bucket_user["backup"].name,
      vault_policy.bucket_user["torrent"].name,
      vault_policy.gpg_key_user["blueberry"].name,
      vault_policy.repo_user["config"].name,
      vault_policy.service_user["jenkins"].name,
      vault_policy.service_user["nix-serve"].name,
    ]
    elderberry = [
      vault_policy.service_user["sing-box"].name,
    ]
    ambrosia = [
      vault_policy.bucket_user["admin"].name,
      vault_policy.externals_user["github"].name,
      vault_policy.gpg_key_user["ambrosia"].name,
      vault_policy.service_user["sing-box"].name,
    ]
  }

  service = {
    terraform = [
      vault_policy.terraform.name,
    ]
    rotate = [
      vault_policy.service_rotate["sing-box"].name,
    ]
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

output "service_role_id" {
  value = {
    for k, v in local.service : k => vault_approle_auth_backend_role.service[k].role_id
  }
}

# machines

resource "vault_approle_auth_backend_role" machine {
  for_each        = local.machine
  backend         = vault_auth_backend.approle.path
  role_name       = each.key
  token_policies  = each.value
  token_ttl       = 3600
  token_type      = "batch"
}

output "machine_role_id" {
  value = {
    for k, v in local.machine : k => vault_approle_auth_backend_role.machine[k].role_id
  }
}
