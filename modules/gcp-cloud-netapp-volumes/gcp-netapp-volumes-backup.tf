
# GCP Cloud NetApp Backup
#

locals {
  google_netapp_backup_vault  = google_netapp_backup_vault.lz
  google_netapp_backup_policy = google_netapp_backup_policy.lz
}

resource "google_netapp_backup_vault" "lz" {
  #
  # GCP NetApp Backup Vaults
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_backup_vault
  for_each = {
    for vault in local.gcp_netapp_backup_vault : vault.resource_index => vault
  }

  name     = each.value.name
  location = each.value.location

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}

resource "google_netapp_backup_policy" "lz" {
  #
  # GCP NetApp Backup Policies
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_backup_policy
  for_each = {
    for policy in local.gcp_netapp_backup_policy : policy.resource_index => policy
  }

  name                 = each.value.name
  location             = each.value.location
  daily_backup_limit   = each.value.daily_backup_limit
  weekly_backup_limit  = each.value.weekly_backup_limit
  monthly_backup_limit = each.value.monthly_backup_limit

  labels      = each.value.labels
  description = each.value.description
  enabled     = each.value.enabled
  project     = each.value.project
}
