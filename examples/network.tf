resource "google_compute_network" "supernetwork" {
  name                    = "supernetwork"
  auto_create_subnetworks = "false"
  project                 = data.google_project.project.name

  # depends_on = [google_project_service.gke_testing_test]
}

resource "google_compute_subnetwork" "subnetwork" {
  for_each                 = var.gcp_subnetworks

  name                     = each.key
  ip_cidr_range            = each.value
  network                  = google_compute_network.supernetwork.self_link
  region                   = each.key
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "router-${var.gcp_region}"
  region  = google_compute_subnetwork.subnetwork[var.gcp_region].region
  network = google_compute_network.supernetwork.self_link
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-${var.gcp_region}"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
