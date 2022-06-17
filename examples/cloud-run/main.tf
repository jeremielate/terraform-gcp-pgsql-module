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

data "google_client_config" "default" {
}

data "google_project" "project" {
}

resource "google_project_service" "gke_testing_test" {
  for_each = toset([
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ])

  project                    = "padok-test"
  service                    = each.value
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_service_account" "cloud_run_sql_client" {
  account_id   = "cloud-run-sql-client"
  display_name = "Service Account for accessing Cloud SQL (Cloud Run)"

  depends_on = [google_project_service.gke_testing_test]
}

module "database" {
  source = "../../"

  name                = "padok"
  tier                = "db-f1-micro"
  region              = "europe-west1"
  public              = true
  compute_network_id  = google_compute_network.supernetwork.id
  deletion_protection = false
  backup_enabled      = false

  databases = [
    "test"
  ]

  builtin_users = [
    "test",
  ]
}

# This container registry is used for storing images needed by Cloud Run
# Don't forget to delete the backing storage bucket after deletion of this resource
resource "google_container_registry" "registry" {
  project  = "padok-test"
  location = "EU"
}

resource "google_project_iam_member" "iam_sa_cloudsql_instance_user" {
  project = data.google_project.project.id
  role    = "roles/cloudsql.instanceUser"
  member  = format("serviceAccount:%s", google_service_account.cloud_run_sql_client.email)
}

resource "google_project_iam_member" "iam_sa_cloudsql_client" {
  project = data.google_project.project.id
  role    = "roles/cloudsql.client"
  member  = format("serviceAccount:%s", google_service_account.cloud_run_sql_client.email)
}


locals {
  pg_conn = "postgresql://test:${urlencode(module.database.user_passwords["test"])}@/test?host=/cloudsql/${urlencode(module.database.connection_name)}&sslmode=disable"
}

resource "google_cloud_run_service" "default" {
  name     = "test-pg"
  location = "europe-west1"

  template {
    spec {
      containers {
        image = "eu.gcr.io/padok-test/test:latest" # use a container hosted on gcr.io or docker.pkg.dev only
        env {
          name  = "PG_DB_URL"
          value = local.pg_conn
        }
      }
      service_account_name = google_service_account.cloud_run_sql_client.email
    }

    metadata {
      annotations = {
        # autoscale maximum replicas count
        "autoscaling.knative.dev/maxScale" = "2"
        # This annotation notifies Cloud Run to create the auth proxy
        "run.googleapis.com/cloudsql-instances" = module.database.connection_name
        "run.googleapis.com/client-name"        = "terraform"
      }
    }
  }

  depends_on                 = [google_project_service.gke_testing_test]
  autogenerate_revision_name = true
}

# Allow any user to call the service defined above (no authentication)
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Outputs the url to call the service
output "service_url" {
  value = google_cloud_run_service.default.status[0].url
}
