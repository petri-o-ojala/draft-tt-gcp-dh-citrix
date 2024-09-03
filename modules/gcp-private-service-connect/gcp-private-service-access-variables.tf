#
# GCP Private Service Access
#

variable "psa" {
  description = "GCP Private Service Access configurations"
  type = object({
    service = optional(map(object({
      network = string
      address = optional(list(object({
        name          = string
        description   = optional(string)
        region        = optional(string)
        project       = optional(string)
        address       = optional(string)
        address_type  = optional(string, "INTERNAL")
        purpose       = optional(string, "VPC_PEERING")
        prefix_length = optional(number)
        ip_version    = optional(string)
      })))
    })))
  })
  default = {}
}

locals {
  #
  # GCP Private Service Access networks
  #
  gcp_psa_network = flatten([
    for psa_network_id, psa_network in coalesce(try(var.psa.service, null), {}) : merge(
      psa_network,
      {
        resource_index = join("_", [psa_network_id])
      }
    )
  ])

  #
  # GCP Private Service Access address allocations
  #
  gcp_psa_address = flatten([
    for psa_network_id, psa_network in coalesce(try(var.psa.service, null), {}) : [
      for psa_address in coalesce(psa_network.address, []) : merge(
        psa_address,
        {
          network        = psa_network.network
          resource_index = join("_", [psa_network_id, psa_address.name])
        }
      )
    ]
  ])
}
