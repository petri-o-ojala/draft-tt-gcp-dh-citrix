#
# Input references to other resources
#

variable "reference" {
  description = "GCP Resource references"
  type = object({
    gcp_compute_instance_group_manager      = optional(map(any))
    gcp_compute_instance_group              = optional(map(any))
    gcp_network_endpoint_group              = optional(map(any))
    gcp_certificate_manager_certificate     = optional(map(any))
    gcp_certificate_manager_certificate_map = optional(map(any))
  })
  default = {}
}

locals {
  gcp_compute_instance_group_manager      = coalesce(var.reference.gcp_compute_instance_group_manager, {})
  gcp_compute_instance_group              = coalesce(var.reference.gcp_compute_instance_group, {})
  gcp_network_endpoint_group              = coalesce(var.reference.gcp_network_endpoint_group, {})
  gcp_certificate_manager_certificate     = coalesce(var.reference.gcp_certificate_manager_certificate, {})
  gcp_certificate_manager_certificate_map = coalesce(var.reference.gcp_certificate_manager_certificate_map, {})
}
