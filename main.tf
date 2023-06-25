resource "google_project_service" "enable_api" {
    for_each = {
        "iam" = "iam.googleapis.com"
        "workstation" = "workstations.googleapis.com"
    }
    project = var.project_id
    service = each.value
    timeouts {
    create = "30m"
    update = "40m"
    }
    disable_dependent_services = true
}

resource "google_workstations_workstation_cluster" "demo_workstation_cluster" {
    provider               = google-beta
    workstation_cluster_id = "demo-workstation-cluster"
    network                = google_compute_network.demo_network.id
    subnetwork             = google_compute_subnetwork.demo_subnetwork.id
    location               = var.region
    project                = var.project_id
}

resource "google_workstations_workstation_config" "demo_workstation_config" {
    provider               = google-beta
    workstation_config_id  = "demo-workstation-config"
    workstation_cluster_id = google_workstations_workstation_cluster.demo_workstation_cluster.workstation_cluster_id
    location               = var.region
    project                = var.project_id
    idle_timeout = "600s"

    host {
        gce_instance {
        machine_type                = "e2-standard-4"
        boot_disk_size_gb           = 35
        disable_public_ip_addresses = false
        }
    }
}

resource "google_workstations_workstation" "demo_workstation" {
  provider               = google-beta
  workstation_id         = "demo-workstation"
  workstation_config_id  = google_workstations_workstation_config.demo_workstation_config.workstation_config_id
  workstation_cluster_id = google_workstations_workstation_cluster.demo_workstation_cluster.workstation_cluster_id
  location               = var.region
  project                = var.project_id
}

resource "google_workstations_workstation_iam_binding" "demo_workstation_binding" {
  provider = google-beta
  project = google_workstations_workstation.demo_workstation.project
  location = google_workstations_workstation.demo_workstation.location
  workstation_cluster_id = google_workstations_workstation.demo_workstation.workstation_cluster_id
  workstation_config_id = google_workstations_workstation.demo_workstation.workstation_config_id
  workstation_id = google_workstations_workstation.demo_workstation.workstation_id
  role = "roles/workstations.user"
  members = [
    "user:aravindgcp@townpoints.net",
  ]
}

resource "google_compute_network" "demo_network" {
    project                 = var.project_id
    name                    = "demo-vpc-network"
    auto_create_subnetworks = false
    mtu                     = 1460
}

resource "google_compute_subnetwork" "demo_subnetwork" {
    project       = var.project_id
    name          = "demo-vpc-subnetwork"
    ip_cidr_range = "10.154.0.0/20"
    region        = var.region
    network       = google_compute_network.demo_network.id
}

