#
# GCP Service Account outputs
#

output "gcp_service_account" {
  description = "Service Account resources"
  value       = google_service_account.lz
}
