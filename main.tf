###############################################################################
# Providers
###############################################################################

provider "google" {
  project = var.GOOGLE_PROJECT

  # NOTE:
  # This expects a *region* (e.g. europe-central2).
  # In this module we also use GOOGLE_REGION as GKE "location" (region OR zone).
  # For a cleaner design, split into GOOGLE_REGION (region) + GKE_LOCATION (region/zone).
  region = var.GOOGLE_REGION
}

###############################################################################
# GKE Cluster
###############################################################################

resource "google_container_cluster" "this" {
  name     = var.GKE_CLUSTER_NAME

  # GKE location can be either region (regional cluster) or zone (zonal cluster),
  # e.g. "europe-central2" or "europe-central2-a"
  location = var.GOOGLE_REGION

  # Enable/disable deletion protection via variable
  deletion_protection = var.DELETION_PROTECTION

  # Required field. We remove the default node pool and create our own node pool below.
  initial_node_count       = 1
  remove_default_node_pool = true

  workload_identity_config {
    workload_pool = "${var.GOOGLE_PROJECT}.svc.id.goog"
  }

  # Minimal node_config block (required for workload_metadata_config)
  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

###############################################################################
# Node Pool
###############################################################################

resource "google_container_node_pool" "this" {
  name     = var.GKE_POOL_NAME
  project  = var.GOOGLE_PROJECT
  cluster  = google_container_cluster.this.name
  location = google_container_cluster.this.location

  node_count = var.GKE_NUM_NODES

  node_config {
    machine_type = var.GKE_MACHINE_TYPE
  }
}

###############################################################################
# Auth helper module (kubectl access)
###############################################################################

module "gke_auth" {
  depends_on = [google_container_cluster.this]

  source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version = ">= 24.0.0"

  project_id   = var.GOOGLE_PROJECT
  cluster_name = google_container_cluster.this.name
  location     = google_container_cluster.this.location
}

###############################################################################
# Data sources
###############################################################################

data "google_client_config" "current" {}

data "google_container_cluster" "main" {
  name     = google_container_cluster.this.name
  location = google_container_cluster.this.location
}
