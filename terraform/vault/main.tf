terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "4.4.0"
    }
  }
}

variable "vault_token" {}

provider "vault" {
  address = "http://blueberry.wg:8200"
  token = var.vault_token
}
