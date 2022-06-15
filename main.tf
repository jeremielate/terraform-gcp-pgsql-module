data "google_project" "project" {
}

resource "google_project_service" "cloudsql" {
  project            = data.google_project.project_id
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_compute_global_address" "db_priv_ip" {
  name         = "${var.name}-db-priv-ip"
  purpose      = "VPC_PEERING"
  address_type = "INTERNAL"
  network      = google_compute_network.supernetwork.id
}

resource "google_service_networking_connection" "db" {
  network                 = google_compute_network.supernetwork.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_priv_ip.name]

  depends_on = [google_project_service.cloudsql]
}

# resource "random_string" "db_name" {
#   length  = 4
#   numeric = false
#   upper   = false
#   special = false
# }

resource "google_sql_database_instance" "db" {
  name             = var.name
  database_version = var.database_version
  region           = var.region

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    // public ip configuration 
    dynamic "ip_configuration" {
      for_each = var.public ? toset(["public"]) : {}

      content {
        ipv4_enabled = true # public ip address
      }
    }

    // private ip configuration 
    dynamic "ip_configuration" {
      for_each = var.public ? {} : toset(["private"])
      content {
        ipv4_enabled    = false
        private_network = var.compute_network_id
      }
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = false
      start_time                     = "23:00"
      transaction_log_retention_days = 7

      backup_retention_settings {
        retained_backups = 7
      }
    }
  }

  deletion_protection = var.deletion_protection

  timeouts {
    // Updates can be slow on big instances
    update = "1h"
    delete = "1h"
  }

  depends_on = [google_service_networking_connection.db]
}

resource "google_sql_database" "db" {
  for_each = var.databases

  name     = each.key
  instance = google_sql_database_instance.db.name
}

resource "random_password" "db" {
  for_each = var.databases

  length = 32
  keepers = {
    name = each.key
  }
}

resource "google_sql_user" "db" {
  for_each = var.databases

  name     = each.value.username
  instance = google_sql_database_instance.db.name
  password = random_password.db[each.key].result
}
