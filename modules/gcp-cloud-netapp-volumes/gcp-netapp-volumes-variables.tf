#
# GCP NetApp Volumes
#

variable "netapp" {
  description = "GCP NetApp Volumes"
  type = object({
    active_directory = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_active_directory
      name                   = string
      domain                 = string
      dns                    = string
      net_bios_prefix        = string
      username               = string
      password               = string
      location               = string
      labels                 = optional(map(string))
      project                = optional(string)
      site                   = optional(string)
      organizational_unit    = optional(string)
      aes_encryption         = optional(bool)
      backup_operators       = optional(list(string))
      security_operators     = optional(list(string))
      kdc_hostname           = optional(string)
      kdc_ip                 = optional(string)
      nfs_users_with_ldap    = optional(bool)
      description            = optional(string)
      ldap_signing           = optional(bool)
      encrypt_dc_connections = optional(bool)
    })))
    storage_pool = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_storage_pool
      name             = string
      service_level    = string
      capacity_gib     = string
      network          = string
      location         = string
      project          = optional(string)
      labels           = optional(map(string))
      description      = optional(string)
      active_directory = optional(string)
      kms_config       = optional(string)
      ldap_enabled     = optional(bool)
    })))
    volume = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume
      name               = string
      share_name         = string
      storage_pool       = string
      capacity_gib       = string
      protocols          = optional(list(string))
      location           = string
      project            = optional(string)
      smb_settings       = optional(string)
      unix_permissions   = optional(string)
      labels             = optional(map(string))
      description        = optional(string)
      security_style     = optional(string)
      kerberos_enabled   = optional(bool)
      restricted_actions = optional(list(string))
      deletion_policy    = optional(string)
      export_policy = optional(object({
        rules = list(object({
          allowed_clients       = optional(list(string))
          has_root_access       = optional(bool)
          access_type           = optional(string)
          nfsv3                 = optional(bool)
          nfsv4                 = optional(bool)
          kerberos5_read_only   = optional(bool)
          kerberos5_read_write  = optional(bool)
          kerberos5i_read_only  = optional(bool)
          kerberos5i_read_write = optional(bool)
          kerberos5p_read_only  = optional(bool)
          kerberos5p_read_write = optional(bool)
        }))
      }))
      restore_parameters = optional(object({
        source_snapshot = optional(string)
        source_backup   = optional(string)

      }))
      snapshot_policy = optional(object({
        enabled = optional(bool)
        hourly_schedule = optional(object({
          snapshots_to_keep = number
          minute            = optional(number)
        }))
        daily_schedule = optional(object({
          snapshots_to_keep = number
          minute            = optional(number)
          hour              = optional(number)
        }))
        weekly_schedule = optional(object({
          snapshots_to_keep = number
          minute            = optional(number)
          hour              = optional(number)
          day               = optional(number)
        }))
        monthly_schedule = optional(object({
          snapshots_to_keep = number
          minute            = optional(number)
          hour              = optional(number)
          days_of_month     = optional(number)
        }))
      }))
      backup_config = optional(object({
        backup_policies          = optional(string)
        backup_vault             = optional(string)
        scheduled_backup_enabled = optional(bool)
      }))
    })))
    volume_replication = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume_replication
      name                      = string
      replication_schedule      = string
      location                  = string
      volume_name               = string
      labels                    = optional(map(string))
      project                   = optional(string)
      description               = optional(string)
      delete_destination_volume = optional(bool)
      replication_enabled       = optional(bool)
      force_stopping            = optional(bool)
      wait_for_mirror           = optional(bool)
      destination_volume_parameters = optional(object({
        storage_pool = string
        volume_id    = optional(string)
        share_name   = optional(string)
        description  = optional(string)
      }))
    })))
    volume_snapshot = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume_snapshot
      name        = string
      location    = string
      volume_name = string
      description = optional(string)
      labels      = optional(map(string))
      project     = optional(string)
    })))
    kmsconfig = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_kmsconfig
      name            = string
      location        = string
      crypto_key_name = string
      description     = optional(string)
      labels          = optional(map(string))
      project         = optional(string)
    })))
    backup_vault = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_backup_vault
      name        = string
      location    = string
      labels      = optional(map(string))
      project     = optional(string)
      description = optional(string)
    })))
    backup_policy = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_backup_policy
      name                 = string
      location             = string
      daily_backup_limit   = number
      weekly_backup_limit  = number
      monthly_backup_limit = number
      labels               = optional(map(string))
      project              = optional(string)
      description          = optional(string)
      enabled              = optional(bool)
    })))
  })
  default = {}
}

locals {
  #
  # GCP NetApp Volumes
  #
  gcp_netapp_storage_pool = flatten([
    for pool_id, pool in coalesce(try(var.netapp.storage_pool, null), {}) : merge(
      pool,
      {
        resource_index = join("_", [pool_id])
      }
    )
  ])

  gcp_netapp_volume = flatten([
    for volume_id, volume in coalesce(try(var.netapp.volume, null), {}) : merge(
      volume,
      {
        resource_index = join("_", [volume_id])
      }
    )
  ])

  gcp_netapp_volume_replication = flatten([
    for replication_id, replication in coalesce(try(var.netapp.volume_replication, null), {}) : merge(
      replication,
      {
        resource_index = join("_", [replication_id])
      }
    )
  ])

  gcp_netapp_volume_snapshot = flatten([
    for snapshot_id, snapshot in coalesce(try(var.netapp.volume_snapshot, null), {}) : merge(
      snapshot,
      {
        resource_index = join("_", [snapshot_id])
      }
    )
  ])

  gcp_netapp_kmsconfig = flatten([
    for kmsconfig_id, kmsconfig in coalesce(try(var.netapp.kmsconfig, null), {}) : merge(
      kmsconfig,
      {
        resource_index = join("_", [kmsconfig_id])
      }
    )
  ])

  gcp_netapp_active_directory = flatten([
    for ad_id, ad in coalesce(try(var.netapp.active_directory, null), {}) : merge(
      ad,
      {
        resource_index = join("_", [ad_id])
      }
    )
  ])

  #
  # GCP NetApp Backup
  #

  gcp_netapp_backup_vault = flatten([
    for vault_id, vault in coalesce(try(var.netapp.backup_vault, null), {}) : merge(
      vault,
      {
        resource_index = join("_", [vault_id])
      }
    )
  ])

  gcp_netapp_backup_policy = flatten([
    for policy_id, policy in coalesce(try(var.netapp.backup_policy, null), {}) : merge(
      policy,
      {
        resource_index = join("_", [policy_id])
      }
    )
  ])
}
