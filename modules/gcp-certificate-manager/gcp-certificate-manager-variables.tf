#
# GCP Certificate Manager
#

variable "certificate_manager" {
  description = "GCP Certificate Manager configurations"
  type = object(
    {
      certificate = optional(map(object({
        name        = string
        description = optional(string)
        project     = optional(string)
        location    = optional(string)
        labels      = optional(map(string))
        scope       = optional(string)
        self_managed = optional(object({
          pem_certificate = optional(string)
          pem_private_key = optional(string)
        }))
        managed = optional(object({
          domains            = optional(list(string))
          dns_authorizations = optional(list(string))
          issuance_config    = optional(string)
        }))
      })))
      certificate_map = optional(map(object({
        name        = string
        description = optional(string)
        labels      = optional(map(string))
        project     = optional(string)
        entry = optional(list(object({
          name         = string
          certificates = list(string)
          description  = optional(string)
          labels       = optional(map(string))
          hostname     = optional(string)
          matcher      = optional(string)
          project      = optional(string)
        })))
      })))
      dns_authorization = optional(map(object({
        domain      = string
        name        = string
        description = optional(string)
        type        = optional(string)
        labels      = optional(map(string))
        location    = optional(string)
        project     = optional(string)
        managed_zone = optional(object({
          project = string
          name    = string
          ttl     = optional(number)
        }))
      })))
    }
  )
  default = {}
}

locals {
  certificate_manager = var.certificate_manager

  #
  # GCP Certificate Manager DNS Authorisations
  #
  gcp_certificate_manager_dns_authorization = flatten([
    for authorization_id, authorization in coalesce(try(local.certificate_manager.dns_authorization, null), {}) : merge(
      authorization,
      {
        resource_index = join("_", [authorization_id])
      }
    )
  ])

  #
  # GCP Certificate Manager certificates
  #
  gcp_certificate_manager_certificate = flatten([
    for certificate_id, certificate in coalesce(try(local.certificate_manager.certificate, null), {}) : merge(
      certificate,
      {
        resource_index = join("_", [certificate_id])
      }
    )
  ])

  #
  # GCP Certificate Manager certificate maps
  #
  gcp_certificate_manager_certificate_map = flatten([
    for map_id, map in coalesce(try(local.certificate_manager.certificate_map, null), {}) : merge(
      map,
      {
        resource_index = join("_", [map_id])
      }
    )
  ])

  #
  #GCP Certificate Manager certificate map entries
  #
  gcp_certificate_manager_certificate_map_entry = flatten([
    for map_id, map in coalesce(try(local.certificate_manager.certificate_map, null), {}) : [
      for entry in coalesce(map.entry, []) : merge(
        entry,
        {
          map_resource   = google_certificate_manager_certificate_map.lz[join("_", [map_id])]
          project        = coalesce(entry.project, map.project)
          resource_index = join("_", [map_id, entry.name])
        }
      )
    ]
  ])
}
