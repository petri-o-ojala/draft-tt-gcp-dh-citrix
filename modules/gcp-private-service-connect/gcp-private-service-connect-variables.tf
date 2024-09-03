#
# GCP Private Service Connect
#

variable "psc" {
  description = "GCP Private Service Connect configurations"
  type = object({
    forwarding_rule = optional(map(object({
      name                    = string
      project                 = optional(string)
      is_mirroring_collector  = optional(bool)
      description             = optional(string)
      ip_address              = optional(string)
      ip_protocol             = optional(string)
      backend_service         = optional(string)
      load_balancing_scheme   = optional(string)
      network                 = optional(string)
      port_range              = optional(string)
      ports                   = optional(list(string))
      subnetwork              = optional(string)
      target                  = optional(string)
      allow_global_access     = optional(bool)
      labels                  = optional(map(string))
      all_ports               = optional(bool)
      network_tier            = optional(string)
      service_label           = optional(string)
      source_ip_ranges        = optional(list(string))
      allow_psc_global_access = optional(bool)
      no_automate_dns_zone    = optional(bool)
      ip_version              = optional(string)
      region                  = optional(string)
      recreate_closed_psc     = optional(string)
      service_directory_registrations = optional(object({
        namespace = optional(string)
        service   = optional(string)
      }))
      metadata_filters = optional(object({
        filter_match_criteria = optional(string)
        filter_labels = optional(list(object({
          name  = optional(string)
          value = optional(string)
        })))
      }))
    })))
    attachment = optional(map(object({
      name                  = string
      connection_preference = string
      target_service        = string
      nat_subnets           = list(string)
      enable_proxy_protocol = bool
      description           = optional(string)
      domain_names          = optional(list(string))
      consumer_reject_lists = optional(list(string))
      consumer_accept_lists = optional(list(object({
        project_id_or_num = string
        connection_limit  = number
      })))
      reconcile_connections = optional(bool)
      region                = optional(string)
      project               = optional(string)
    })))
    address = optional(map(object({
      name               = string
      description        = optional(string)
      region             = optional(string)
      project            = optional(string)
      address            = optional(string)
      address_type       = optional(string)
      purpose            = optional(string)
      network_tier       = optional(string)
      subnetwork         = optional(string)
      labels             = optional(map(string))
      network            = optional(string)
      prefix_length      = optional(number)
      ip_version         = optional(string)
      ipv6_endpoint_type = optional(string)
      dns = optional(object({
        name            = string
        type            = optional(string, "A")
        ttl             = optional(number, 300)
        managed_zone    = string
        project         = optional(string)
        rr_data_address = optional(bool)
        rr_data         = optional(list(string))
      }))
    })))
  })
  default = {}
}

locals {
  psc_address         = coalesce(try(var.psc.address, null), {})
  psc_attachment      = coalesce(try(var.psc.attachment, null), {})
  psc_forwarding_rule = coalesce(try(var.psc.forwarding_rule, {}), {})

  #
  # GCP Compute Address allocations for Private Service Connect
  #
  gcp_psc_address = flatten([
    for psc_address_id, psc_address in coalesce(try(local.psc_address, null), {}) : merge(
      psc_address,
      {
        resource_index = join("_", [psc_address_id])
      }
    )
  ])

  #
  # GCP PSC Attachments
  #
  gcp_psc_attachment = flatten([
    for attachment_id, attachment in coalesce(try(local.psc_attachment, null), {}) : merge(
      attachment,
      {
        resource_index = join("_", [attachment_id])
      }
    )
  ])

  #
  # GCP Forwarding rules for PSC
  #
  gcp_psc_forwarding_rule = flatten([
    for rule_id, rule in coalesce(try(local.psc_forwarding_rule, null), {}) : merge(
      rule,
      {
        resource_index = join("_", [rule_id])
      }
    )
  ])
}
