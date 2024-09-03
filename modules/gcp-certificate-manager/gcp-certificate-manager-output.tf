#
# Terraform module outputs
#

output "gcp_certificate_manager_dns_authorization" {
  description = "GCP Certificate Manager DNS Authorization resources"
  value       = google_certificate_manager_dns_authorization.lz
  sensitive   = true
}

output "gcp_certificate_manager_certificate" {
  description = "GCP Certificate Manager Certificate resources"
  value       = google_certificate_manager_certificate.lz
}

output "gcp_certificate_manager_certificate_map" {
  description = "GCP Certificate Manager Certificate Map resources"
  value       = google_certificate_manager_certificate_map.lz
}
