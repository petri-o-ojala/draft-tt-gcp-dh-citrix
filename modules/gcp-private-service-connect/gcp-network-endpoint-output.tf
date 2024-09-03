#
# Terraform module outputs
#

output "gcp_network_endpoint_group" {
  description = "GCP Network Endpoint Group resources"
  value = merge(
    google_compute_network_endpoint_group.lz,
    google_compute_region_network_endpoint_group.lz
  )
}
