variable "neg" {
  description = "GCP Network Endpoint Group configurations"
  type = object({
    network_endpoint_group = optional(map(object({
      name                  = string
      network               = string
      region                = optional(string)
      description           = optional(string)
      network_endpoint_type = optional(string)
      psc_target_service    = optional(string)
      subnetwork            = optional(string)
      default_port          = optional(number)
      zone                  = optional(string)
      project               = optional(string)
      cloud_run = optional(object({
        service  = optional(string)
        tag      = optional(string)
        url_mask = optional(string)
      }))
      app_engine = optional(object({
        service  = optional(string)
        version  = optional(string)
        url_mask = optional(string)
      }))
      cloud_function = optional(object({
        function = optional(string)
        url_mask = optional(string)
      }))
      serverless_deployment = optional(object({
        platform = optional(string)
        resource = optional(string)
        version  = optional(string)
        url_mask = optional(string)
      }))
    })))
    network_endpoint = optional(map(object({
      network_endpoint_group = string
      region                 = optional(string)
      zone                   = optional(string)
      project                = optional(string)
      ip_address             = optional(string)
      port                   = optional(number)
      fqdn                   = optional(string)
      network_endpoints = optional(list(object({
        instance   = optional(string)
        port       = optional(number)
        ip_address = string
      })))
    })))
  })
  default = {}
}

locals {
  network_endpoint_group = coalesce(try(var.neg.network_endpoint_group, null), {})
  network_endpoint       = coalesce(try(var.neg.network_endpoint, null), {})

  #
  # GCP NEGs
  #
  gcp_network_endpoint_group = flatten([
    for neg_id, neg in coalesce(try(local.network_endpoint_group, null), {}) : merge(
      neg,
      {
        resource_index = join("_", [neg_id])
      }
    )
  ])

  gcp_network_endpoint = flatten([
    for network_endpoint_id, network_endpoint in coalesce(try(local.network_endpoint, null), {}) : merge(
      network_endpoint,
      {
        resource_index = join("_", [network_endpoint_id])
      }
    )
  ])
}
