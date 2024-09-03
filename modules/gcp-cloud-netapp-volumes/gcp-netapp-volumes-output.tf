#
# Terraform module outputs
#

output "gcp_netapp_storage_pool" {
  description = "GCP Storage Pools"
  value       = google_netapp_storage_pool.lz
}

output "gcp_netapp_volume" {
  description = "GCP NetApp Volumes"
  value       = google_netapp_volume.lz
}

output "gcp_netapp_backup_vault" {
  description = "GCP NetApp Backup Vaults"
  value       = google_netapp_backup_vault.lz
}

output "gcp_netapp_backup_policy" {
  description = "GCP NetApp Backup Policies"
  value       = google_netapp_backup_policy.lz
}

output "gcp_netapp_volume_replication" {
  description = "GCP NetApp Volume Replications"
  value       = google_netapp_volume_replication.lz
}
