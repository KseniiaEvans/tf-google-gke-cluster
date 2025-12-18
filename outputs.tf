###############################################################################
# Outputs for Kubernetes auth module (kubectl / providers)
###############################################################################

output "config_host" {
  description = "Kubernetes API server URL"
  value       = "https://${data.google_container_cluster.main.endpoint}"
}

output "config_token" {
  description = "Access token for authenticating to the Kubernetes API"
  value       = data.google_client_config.current.access_token
  sensitive   = true
}

output "config_ca" {
  description = "Cluster CA certificate (decoded)"
  value = base64decode(
    data.google_container_cluster.main.master_auth[0].cluster_ca_certificate
  )
  sensitive = true
}

###############################################################################
# Cluster identifiers
###############################################################################

output "name" {
  description = "GKE cluster name"
  value       = google_container_cluster.this.name
}

output "location" {
  description = "GKE cluster location (region or zone)"
  value       = google_container_cluster.this.location
}

output "project" {
  description = "GCP project ID"
  value       = var.GOOGLE_PROJECT
}

output "cluster_id" {
  description = "Full resource ID of the cluster"
  value       = google_container_cluster.this.id
}
