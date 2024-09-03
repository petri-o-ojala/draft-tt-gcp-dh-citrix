#
# Terraform module outputs
#

output "gcp_compute_instance_group_manager" {
  description = "GCE Instance Group Manager resources"
  value = merge(
    google_compute_region_instance_group_manager.lz,
    google_compute_instance_group_manager.lz
  )
}

output "gcp_compute_instance_group" {
  description = "GCE Instance Group resources"
  value       = google_compute_instance_group.lz
}
