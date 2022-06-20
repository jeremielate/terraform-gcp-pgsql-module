terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.20"
    }
  }

  required_version = ">= 1.1"
}

provider "google" {
  project = "padok-test"
  region  = "europe-west1"
}

data "http" "current_ip" {
  url = "https://ipinfo.io"
}

locals {
  username = "test"
}

module "database" {
  source = "../../"

  name                = "padok"
  tier                = "db-f1-micro"
  availability_type   = "ZONAL"
  region              = "europe-west1"
  public              = true
  vpc_peering_enabled = false
  deletion_protection = false
  backup_enabled      = false

  databases = [
    "test"
  ]

  authorized_networks = {
    # Allow the ip of this host to connect to the database
    default = {
      value = "${jsondecode(data.http.current_ip.body).ip}/32"
      # expiration_time = timeadd(timestamp(), "1h")
    }
  }

  builtin_users = [
    local.username,
  ]
}

output "db_connection_name" {
  value = module.database.connection_name
}

output "db_public_ip_address" {
  value = module.database.public_ip_address
}

output "db_server_ca_cert" {
  value = module.database.server_ca_cert
}

output "db_user_test_certificate" {
  value     = module.database.user_credentials[local.username]
  sensitive = true
}

locals {
  pg_conn = "postgresql://test:${urlencode(module.database.user_credentials[local.username].password)}@/test?host=${module.database.public_ip_address}&sslmode=require"
}

output "db_connection_string" {
  value     = local.pg_conn
  sensitive = true
}
