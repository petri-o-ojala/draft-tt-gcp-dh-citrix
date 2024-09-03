#
# GCP Filestore
#

locals {
  google_filestore_instance = google_filestore_instance.lz
  google_filestore_snapshot = google_filestore_snapshot.lz
  google_filestore_backup   = google_filestore_backup.lz
}

resource "google_filestore_instance" "lz" {
  #
  # GCP Filestore instances
  #
  for_each = {
    for filestore in local.gcp_filestore_instance : filestore.resource_index => filestore
  }

  name = each.value.name
  tier = each.value.tier

  description  = each.value.description
  labels       = each.value.labels
  kms_key_name = each.value.kms_key_name
  location     = each.value.location
  project      = each.value.project

  dynamic "file_shares" {
    # (Required) File system shares on the instance. For this version, only a single file share is supported.
    for_each = coalesce(each.value.file_shares, [])

    content {
      name          = file_shares.value.name
      capacity_gb   = file_shares.value.capacity_gb
      source_backup = file_shares.value.source_backup

      dynamic "nfs_export_options" {
        # (Optional) Nfs Export Options. There is a limit of 10 export options per file share.
        for_each = coalesce(file_shares.value.nfs_export_options, [])

        content {
          ip_ranges   = nfs_export_options.value.ip_ranges
          access_mode = nfs_export_options.value.access_mode
          squash_mode = nfs_export_options.value.squash_mode
          anon_uid    = nfs_export_options.value.anon_uid
          anon_gid    = nfs_export_options.value.anon_gid
        }
      }
    }
  }

  dynamic "networks" {
    # (Required) VPC networks to which the instance is connected. For this version, only a single network is supported. 
    for_each = coalesce(each.value.networks, [])

    content {
      network           = networks.value.network
      modes             = networks.value.modes
      reserved_ip_range = networks.value.reserved_ip_range
      connect_mode      = networks.value.connect_mode
    }
  }
}

#
# GCP Filestore snapshots
#

resource "google_filestore_snapshot" "lz" {
  #
  # GCP Filestore snapshots
  #
  for_each = {
    for snapshot in local.gcp_filestore_snapshot : snapshot.resource_index => snapshot
  }

  name     = each.value.name
  location = each.value.location
  instance = lookup(local.google_filestore_instance, each.value.instance, null) == null ? each.value.instance : local.google_filestore_instance[each.value.instance].id

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}

#
# GCP Filestore backups
#

resource "google_filestore_backup" "lz" {
  #
  # GCP Filestore backups
  #
  for_each = {
    for backup in local.gcp_filestore_backup : backup.resource_index => backup
  }

  name              = each.value.name
  source_instance   = lookup(local.google_filestore_instance, each.value.instance, null) == null ? each.value.instance : local.google_filestore_instance[each.value.instance].id
  source_file_share = each.value.source_file_share
  location          = each.value.location

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}
