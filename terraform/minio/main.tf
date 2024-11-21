terraform {
  required_providers {
    minio = {
      version = "~> 3.2.1"
      source  = "aminueza/minio"
    }
  }
}

variable "minio_secret" {}
variable "backup_secret" {}
variable "torrent_secret" {}

provider "minio" {
  minio_server = "blueberry.wg:9000"
  minio_user = "admin"
  minio_password = var.minio_secret
}

locals {
  buckets = [ "backup", "torrent" ]
  secrets = {
    backup = var.backup_secret
    torrent = var.torrent_secret
  }
}
