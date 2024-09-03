#
# Terraform module outputs
#

output "gcp_compute_instance" {
  description = "GCE Instance resources"
  value       = google_compute_instance.lz
  sensitive   = true
}

output "gcp_compute_address" {
  description = "GCE IP Address resources"
  value       = google_compute_address.lz
}

output "gcp_compute_resource_policy" {
  description = "GCE Resource Policy resources"
  value       = google_compute_resource_policy.lz
}
