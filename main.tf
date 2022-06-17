data "google_project" "project" {
}

resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
  ])

  project            = data.google_project.project.id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_global_address" "db_ip" {
  for_each = var.public ? toset([]) : toset(["private"])

  name          = "${var.name}-db-priv-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.network_prefix_length
  network       = var.compute_network_id
}

resource "google_service_networking_connection" "db" {
  for_each = var.public ? toset([]) : toset(["private"])

  network                 = var.compute_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.db_ip[each.key].name]

  depends_on = [google_project_service.services]
}

# allows to recreate the db instance with a new name because
# the previous name remains allocated after destruction for a few days
resource "random_string" "db_name_suffix" {
  length  = 4
  numeric = false
  upper   = false
  special = false
}

resource "google_sql_database_instance" "db" {
  name             = "${var.name}-${random_string.db_name_suffix.result}" # unique name
  database_version = local.database_version
  region           = var.region

  settings {
    tier              = var.tier
    availability_type = var.availability_type

    // public ip configuration
    dynamic "ip_configuration" {
      for_each = var.public ? toset(["public"]) : toset([])

      content {
        ipv4_enabled = true # public ip address
        require_ssl  = true
      }
    }

    // private ip configuration
    dynamic "ip_configuration" {
      for_each = var.public ? toset([]) : toset(["private"])
      content {
        ipv4_enabled    = false
        require_ssl     = true
        private_network = var.compute_network_id
      }
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      point_in_time_recovery_enabled = var.backup_point_in_time_recovery_enabled
      start_time                     = var.backup_start_time
      transaction_log_retention_days = var.backup_transaction_log_retention_days

      backup_retention_settings {
        retained_backups = var.backup_retained_backups
      }
    }

    user_labels = var.user_labels
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

resource "random_password" "db_user" {
  for_each = var.builtin_users

  length = local.user_password_length
}

resource "google_sql_user" "db_user" {
  for_each = var.builtin_users

  instance = google_sql_database_instance.db.name
  name     = each.value
  type     = "BUILT_IN"
  password = random_password.db_user[each.key].result
}

resource "google_sql_user" "db_user_u" {
  for_each = var.iam_users

  instance = google_sql_database_instance.db.name
  name     = each.value
  type     = "CLOUD_IAM_USER"
}

resource "google_project_iam_member" "iam_user_cloudsql_instance_user" {
  for_each = var.iam_service_accounts

  project = data.google_project.project.id
  role    = "roles/cloudsql.instanceUser"
  member  = format("user:%s", each.value)
}

resource "google_project_iam_member" "iam_user_cloudsql_client" {
  for_each = var.iam_service_accounts

  project = data.google_project.project.id
  role    = "roles/cloudsql.client"
  member  = format("user:%s", each.value)
}

resource "google_sql_user" "db_user_sa" {
  for_each = var.iam_service_accounts

  instance = google_sql_database_instance.db.name
  name     = trimsuffix(each.value, ".gserviceaccount.com")
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

resource "google_project_iam_member" "iam_sa_cloudsql_instance_user" {
  for_each = var.iam_service_accounts

  project = data.google_project.project.id
  role    = "roles/cloudsql.instanceUser"
  member  = format("serviceAccount:%s", each.value)
}

resource "google_project_iam_member" "iam_sa_cloudsql_client" {
  for_each = var.iam_service_accounts

  project = data.google_project.project.id
  role    = "roles/cloudsql.client"
  member  = format("serviceAccount:%s", each.value)
}
