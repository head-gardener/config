resource "vault_token" "terraform" {
  policies = ["root"]
  renewable = false
  ttl = "30d"
}

output "terraform_token" {
  value = vault_token.terraform.client_token
  sensitive = true
}
