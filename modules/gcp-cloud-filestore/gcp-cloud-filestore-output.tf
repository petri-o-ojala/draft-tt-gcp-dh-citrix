#
# Terraform module outputs
#

output "gcp_filestore_instance" {
  description = "GCP Filestore instance resources"
  value       = google_filestore_instance.lz
}

output "gcp_filestore_snapshot" {
  description = "GCP Filestore snapshot resources"
  value       = google_filestore_snapshot.lz
}

output "gcp_filestore_backup" {
  description = "GCP Filestore backup resources"
  value       = google_filestore_backup.lz
}
