terraform {
  required_providers {
    minio = {
      version = "~> 2.5.1"
      source  = "aminueza/minio"
    }
  }
}

variable "minio_secret" {}
variable "backup_secret" {}

provider "minio" {
  minio_server = "blueberry:9000"
  minio_user = "admin"
  minio_password = var.minio_secret
}

locals {
  buckets = [ "backup" ]
  secrets = {
    backup = var.backup_secret
  }
}
