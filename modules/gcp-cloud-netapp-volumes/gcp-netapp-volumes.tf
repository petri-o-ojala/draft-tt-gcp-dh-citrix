#
# GCP Cloud NetApp Volumes
#

locals {
  google_netapp_storage_pool = google_netapp_storage_pool.lz
  google_netapp_volume       = google_netapp_volume.lz
}

resource "google_netapp_storage_pool" "lz" {
  #
  # GCP NetApp Storage Pools
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_storage_pool
  for_each = {
    for pool in local.gcp_netapp_storage_pool : pool.resource_index => pool
  }

  name          = each.value.name
  service_level = each.value.service_level
  capacity_gib  = each.value.capacity_gib
  network       = each.value.network
  location      = each.value.location
  project       = each.value.project

  description      = each.value.description
  labels           = each.value.labels
  active_directory = each.value.active_directory
  kms_config       = each.value.kms_config
  ldap_enabled     = each.value.ldap_enabled
}

resource "google_netapp_kmsconfig" "lz" {
  #
  # GCP NetApp Volumes
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_kmsconfig
  for_each = {
    for kmsconfig in local.gcp_netapp_kmsconfig : kmsconfig.resource_index => kmsconfig
  }

  name            = each.value.name
  location        = each.value.location
  crypto_key_name = each.value.crypto_key_name

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}

resource "google_netapp_volume" "lz" {
  #
  # GCP NetApp Volumes
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume
  for_each = {
    for volume in local.gcp_netapp_volume : volume.resource_index => volume
  }

  name         = each.value.name
  share_name   = each.value.share_name
  storage_pool = lookup(local.google_netapp_storage_pool, each.value.storage_pool, null) == null ? each.value.storage_pool : local.google_netapp_storage_pool[each.value.storage_pool].name
  capacity_gib = each.value.capacity_gib
  protocols    = each.value.protocols
  location     = each.value.location
  project      = each.value.project

  smb_settings       = each.value.smb_settings
  unix_permissions   = each.value.unix_permissions
  labels             = each.value.labels
  description        = each.value.description
  security_style     = each.value.security_style
  kerberos_enabled   = each.value.kerberos_enabled
  restricted_actions = each.value.restricted_actions
  deletion_policy    = each.value.deletion_policy

  dynamic "export_policy" {
    for_each = try(each.value.export_policy, null) == null ? [] : [1]

    content {
      dynamic "rules" {
        for_each = coalesce(each.value.export_policy.rules, [])

        content {
          allowed_clients       = rules.value.allowed_clients
          has_root_access       = rules.value.has_root_access
          access_type           = rules.value.access_type
          nfsv3                 = rules.value.nfsv3
          nfsv4                 = rules.value.nfsv4
          kerberos5_read_only   = rules.value.kerberos5_read_only
          kerberos5_read_write  = rules.value.kerberos5_read_write
          kerberos5i_read_only  = rules.value.kerberos5i_read_only
          kerberos5i_read_write = rules.value.kerberos5i_read_write
          kerberos5p_read_only  = rules.value.kerberos5p_read_only
          kerberos5p_read_write = rules.value.kerberos5p_read_write
        }
      }
    }
  }

  dynamic "restore_parameters" {
    for_each = try(each.value.restore_parameters, null) == null ? [] : [1]

    content {
      source_snapshot = each.value.restore_parameters.source_snapshot
      source_backup   = each.value.restore_parameters.source_backup
    }
  }

  dynamic "snapshot_policy" {
    for_each = try(each.value.snapshot_policy, null) == null ? [] : [1]

    content {
      enabled = each.value.snapshot_policy.enabled

      dynamic "hourly_schedule" {
        for_each = try(each.value.snapshot_policy.hourly_schedule, null) == null ? [] : [1]

        content {
          snapshots_to_keep = each.value.snapshot_policy.hourly_schedule.snapshots_to_keep
          minute            = each.value.snapshot_policy.hourly_schedule.minute
        }
      }

      dynamic "daily_schedule" {
        for_each = try(each.value.snapshot_policy.daily_schedule, null) == null ? [] : [1]

        content {
          snapshots_to_keep = each.value.snapshot_policy.daily_schedule.snapshots_to_keep
          minute            = each.value.snapshot_policy.daily_schedule.minute
          hour              = each.value.snapshot_policy.daily_schedule.hour
        }
      }

      dynamic "weekly_schedule" {
        for_each = try(each.value.snapshot_policy.weekly_schedule, null) == null ? [] : [1]

        content {
          snapshots_to_keep = each.value.snapshot_policy.weekly_schedule.snapshots_to_keep
          minute            = each.value.snapshot_policy.weekly_schedule.minute
          hour              = each.value.snapshot_policy.weekly_schedule.hour
          day               = each.value.snapshot_policy.weekly_schedule.day
        }
      }

      dynamic "monthly_schedule" {
        for_each = try(each.value.snapshot_policy.monthly_schedule, null) == null ? [] : [1]

        content {
          snapshots_to_keep = each.value.snapshot_policy.monthly_schedule.snapshots_to_keep
          minute            = each.value.snapshot_policy.monthly_schedule.minute
          hour              = each.value.snapshot_policy.monthly_schedule.hour
          days_of_month     = each.value.snapshot_policy.monthly_schedule.days_of_month
        }
      }
    }
  }

  dynamic "backup_config" {
    for_each = try(each.value.backup_config, null) == null ? [] : [1]

    content {
      backup_policies          = each.value.backup_config.backup_policies
      backup_vault             = each.value.backup_config.backup_vault
      scheduled_backup_enabled = each.value.backup_config.scheduled_backup_enabled
    }
  }
}

resource "google_netapp_volume_replication" "ls" {
  #
  # GCP NetApp Volume Replication configurations
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume_replication
  for_each = {
    for replication in local.gcp_netapp_volume_replication : replication.resource_index => replication
  }

  name                 = each.value.name
  replication_schedule = each.value.replication_schedule
  location             = each.value.location
  volume_name          = each.value.volume_name
  labels               = each.value.labels
  project              = each.value.project

  description               = each.value.description
  delete_destination_volume = each.value.delete_destination_volume
  replication_enabled       = each.value.replication_enabled
  force_stopping            = each.value.force_stopping
  wait_for_mirror           = each.value.wait_for_mirror

  dynamic "destination_volume_parameters" {
    for_each = try(each.value.backup_config, null) == null ? [] : [1]

    content {
      storage_pool = each.value.backup_config.storage_pool
      volume_id    = each.value.backup_config.volume_id
      share_name   = each.value.backup_config.share_name
      description  = each.value.backup_config.description
    }
  }
}

resource "google_netapp_volume_snapshot" "ls" {
  #
  # GCP NetApp Volume Snapshot configurations
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume_snapshot
  for_each = {
    for snapshot in local.gcp_netapp_volume_snapshot : snapshot.resource_index => snapshot
  }

  name        = each.value.name
  location    = each.value.location
  volume_name = each.value.volume_name

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}

resource "google_netapp_active_directory" "lz" {
  #
  # GCP NetApp Active Directory configuration
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_active_directory
  for_each = {
    for ad in local.gcp_netapp_active_directory : ad.resource_index => ad
  }

  name            = each.value.name
  domain          = each.value.domain
  dns             = each.value.dns
  net_bios_prefix = each.value.net_bios_prefix
  username        = each.value.username
  password        = each.value.password
  location        = each.value.location
  labels          = each.value.labels
  project         = each.value.project

  site                   = each.value.site
  organizational_unit    = each.value.organizational_unit
  aes_encryption         = each.value.aes_encryption
  backup_operators       = each.value.backup_operators
  security_operators     = each.value.security_operators
  kdc_hostname           = each.value.kdc_hostname
  kdc_ip                 = each.value.kdc_ip
  nfs_users_with_ldap    = each.value.nfs_users_with_ldap
  description            = each.value.description
  ldap_signing           = each.value.ldap_signing
  encrypt_dc_connections = each.value.encrypt_dc_connections
}
