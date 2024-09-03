#
# Terraform module outputs
#

output "gcp_compute_forwarding_rule" {
  description = "GCP Compute Forwarding Rules"
  value = merge(
    google_compute_forwarding_rule.lz,
    google_compute_global_forwarding_rule.lz
  )
}
