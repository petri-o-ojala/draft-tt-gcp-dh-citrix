#
# GCP Service Accounts for Compute Engine resources
#

resource "google_service_account" "compute" {
  #
  # Service Accounts configured together with Compute Engine resources
  #
  for_each = {
    for service_account in local.gcp_compute_service_account : service_account.resource_index => service_account
  }

  account_id   = try(each.value.account_id, null)
  display_name = try(each.value.display_name, null)
  description  = try(each.value.description, null)
  disabled     = try(each.value.disabled, null)
  project      = try(each.value.project, null)
}

resource "time_rotating" "compute" {
  #
  # Rotating clock for Service Account key renewal
  #
  for_each = {
    for service_account in local.gcp_compute_service_account : service_account.resource_index => service_account
    if try(service_account.key.rotation_days, null) != null
  }

  rotation_days = each.value.key.rotation_days
}

resource "google_service_account_key" "compute" {
  #
  # Service Account key renewal
  #
  for_each = {
    for service_account in local.gcp_compute_service_account : service_account.resource_index => service_account
    if try(service_account.key.rotation_days, null) != null
  }

  service_account_id = google_service_account.compute[each.key].name
  key_algorithm      = try(each.value.key.key_algorithm, null)
  public_key_type    = try(each.value.key.public_key_type, null)
  private_key_type   = try(each.value.key.private_key_type, null)
  public_key_data    = try(each.value.key.public_key_data, null)

  keepers = {
    rotation_time = time_rotating.compute[each.key].rotation_rfc3339
  }
}

resource "google_service_account_iam_member" "compute" {
  #
  # Service Account IAM permissions (to access Service Account)
  #
  for_each = {
    for iam in local.gcp_compute_service_account_iam : iam.resource_index => iam
  }

  service_account_id = google_service_account.compute[each.value.service_account].name
  role               = each.value.role
  member             = lookup(local.compute_service_account, each.value.member, null) == null ? each.value.member : google_service_account.compute[each.value.member].member

  depends_on = [
    google_service_account.compute
  ]
}

resource "google_project_iam_member" "compute" {
  #
  # Project level IAM roles for Compute Service Account
  for_each = {
    for iam in local.gcp_compute_project_iam : iam.resource_index => iam
  }

  project = each.value.project_id
  role    = each.value.role
  member  = lookup(local.compute_service_account, each.value.member, null) == null ? each.value.member : google_service_account.compute[each.value.member].member
}
