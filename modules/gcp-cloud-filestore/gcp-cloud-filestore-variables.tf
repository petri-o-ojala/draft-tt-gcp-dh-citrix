#
# GCP Filestore
#

variable "filestore" {
  description = "GCP Filestore configurations"
  type = object({
    instance = optional(map(object({
      name         = string
      tier         = string
      description  = optional(string)
      labels       = optional(map(string))
      kms_key_name = optional(string)
      location     = optional(string)
      project      = optional(string)
      file_shares = list(object({
        name          = string
        capacity_gb   = string
        source_backup = optional(string)
        nfs_export_options = optional(list(object({
          ip_ranges   = optional(list(string))
          access_mode = optional(string)
          squash_mode = optional(string)
          anon_uid    = optional(number)
          anon_gid    = optional(number)
        })))
      }))
      networks = list(object({
        network           = string
        modes             = list(string)
        reserved_ip_range = optional(string)
        connect_mode      = optional(string)
      }))
      dns = optional(list(object({
        name            = string
        type            = optional(string, "A")
        ttl             = optional(number, 300)
        managed_zone    = string
        project         = optional(string)
        rr_data_address = optional(bool)
        rr_data         = optional(list(string))
      })))
    })))
    backup = optional(map(object({
      name              = string
      source_instance   = string
      source_file_share = string
      location          = string
      description       = optional(string)
      labels            = optional(map(string))
      project           = optional(string)
    })))
    snapshot = optional(map(object({
      name        = string
      location    = string
      instance    = string
      description = optional(string)
      labels      = optional(map(string))
      project     = optional(string)
    })))
  })
  default = {}
}

locals {
  filestore_instance = coalesce(try(var.filestore.instance, {}), {})
  filestore_backup   = coalesce(try(var.filestore.backup, {}), {})
  filestore_snapshot = coalesce(try(var.filestore.snapshot, {}), {})

  #
  # GCP Filestore instances
  #
  gcp_filestore_instance = flatten([
    for filestore_id, filestore in coalesce(try(local.filestore_instance, null), {}) : merge(
      filestore,
      {
        resource_index = join("_", [filestore_id])
      }
    )
  ])

  #
  # GCP Filestore instance DNS records
  #
  gcp_filestore_instance_dns = flatten([
    for filestore_id, filestore in coalesce(try(local.filestore_instance, null), {}) : [
      for dns_address in coalesce(filestore.dns, []) : merge(
        dns_address,
        {
          filestore_instance_ip_addresses = local.google_filestore_instance[join("_", [filestore_id])].networks.0.ip_addresses
          resource_index                  = join("_", [filestore_id, dns_address.managed_zone, dns_address.name])
        }
      )
    ]
  ])

  #
  # GCP Filestore snapshots
  #
  gcp_filestore_snapshot = flatten([
    for snapshot_id, snapshot in coalesce(try(local.filestore_snapshot, null), {}) : merge(
      snapshot,
      {
        resource_index = join("_", [snapshot_id])
      }
    )
  ])

  #
  # GCP Filestore backups
  #
  gcp_filestore_backup = flatten([
    for backup_id, backup in coalesce(try(local.filestore_backup, null), {}) : merge(
      backup,
      {
        resource_index = join("_", [backup_id])
      }
    )
  ])
}
