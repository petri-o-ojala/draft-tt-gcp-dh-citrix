#
# Terraform module outputs
#

output "gcp_psc_address" {
  description = "GCP Private Service Connect Address resources"
  value       = google_compute_address.psc
}
