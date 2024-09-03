#
# GCP Deployments
#

#
# Service Accounts for pipelines
#
resource "google_service_account" "lz" {
  for_each = {
    for service_account in local.gcp_service_account : service_account.resource_index => service_account
    if service_account.service_account == null && service_account.account_id != null
  }

  account_id   = each.value.account_id
  display_name = each.value.display_name
  description  = each.value.description
  disabled     = each.value.disabled
  project      = each.value.project
}

#
# Service Account key management
#

resource "time_rotating" "lz" {
  #
  # Rotating clock for Service Account key renewal
  #
  for_each = {
    for service_account in local.gcp_service_account : service_account.resource_index => service_account
    if try(service_account.key.rotation_days, null) != null
  }

  rotation_days = each.value.key.rotation_days
}

resource "google_service_account_key" "lz" {
  #
  # Service Account key renewal
  #
  for_each = {
    for service_account in local.gcp_service_account : service_account.resource_index => service_account
    if try(service_account.key.rotation_days, null) != null
  }

  service_account_id = google_service_account.lz[each.key].name
  key_algorithm      = try(each.value.key.key_algorithm, null)
  public_key_type    = try(each.value.key.public_key_type, null)
  private_key_type   = try(each.value.key.private_key_type, null)
  public_key_data    = try(each.value.key.public_key_data, null)

  keepers = {
    rotation_time = time_rotating.lz[each.key].rotation_rfc3339
  }
}

#
# IAM Permissions for Service Account IAM
#
resource "google_service_account_iam_member" "lz" {
  #
  # Service Account IAM permissions (to access Service Account)
  #
  for_each = {
    for iam in local.service_account_iam : iam.resource_index => iam
  }

  service_account_id = google_service_account.lz[each.value.service_account_resource].name
  role               = each.value.role
  member             = each.value.member
  # member             = lookup(local.gcp_service_account, each.value.member, null) == null ? each.value.member : google_service_account.lz[each.value.member].member

  depends_on = [
    google_service_account.lz
  ]
}

#
# IAM Permissions for Service Accounts to service accounts (e.g. if SA created elsewhere)
#
resource "google_service_account_iam_member" "sa" {
  #
  # Service Account IAM permissions
  #
  for_each = {
    for iam in local.service_account_target_iam : iam.resource_index => iam
  }

  service_account_id = each.value.service_account_id
  role               = each.value.role
  member             = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

#
# IAM Permissions for Service Accounts to projects
#

resource "google_billing_account_iam_member" "lz" {
  for_each = {
    for iam in local.service_account_billing_account_iam : iam.resource_index => iam
  }

  billing_account_id = each.value.billing_account_id
  role               = each.value.role
  member             = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

resource "google_organization_iam_member" "lz" {
  for_each = {
    for iam in local.service_account_organization_iam : iam.resource_index => iam
  }

  org_id = each.value.org_id
  role   = each.value.role
  member = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

resource "google_folder_iam_member" "lz" {
  for_each = {
    for iam in local.service_account_folder_iam : iam.resource_index => iam
  }

  folder = each.value.folder_id
  role   = each.value.role
  member = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

resource "google_project_iam_member" "lz" {
  for_each = {
    for iam in local.service_account_project_iam : iam.resource_index => iam
  }

  project = each.value.project_id
  role    = each.value.role
  member  = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

#
# Google Storage Bucket IAM permissions for Service Accounts
#

resource "google_storage_bucket_iam_member" "lz" {
  for_each = {
    for iam in local.storage_bucket_iam : iam.resource_index => iam
  }

  bucket = each.value.storage_bucket_name
  role   = each.value.role
  member = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member

  dynamic "condition" {
    #  (Optional) An IAM Condition for a given binding.
    for_each = try(each.value.condition, null) == null ? [] : [1]

    content {
      title       = try(each.value.condition.title, null)
      description = try(each.value.condition.description, null)
      expression  = try(each.value.condition.expression, null)
    }
  }
}

#
# Google Cloud Managed Zone IAM permissions for Service Accounts
#

resource "google_dns_managed_zone_iam_member" "lz" {
  for_each = {
    for iam in local.dns_managed_zone_iam : iam.resource_index => iam
  }

  project      = each.value.project
  managed_zone = each.value.managed_zone_name
  role         = each.value.role
  member       = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}

#
# VPC Subnet IAM permissions for Service Accounts
#
resource "google_compute_subnetwork_iam_member" "lz" {
  for_each = {
    for iam in local.service_account_subnetwork_iam : iam.resource_index => iam
  }

  subnetwork = each.value.subnetwork
  role       = each.value.role
  member     = each.value.service_account != null ? each.value.service_account : google_service_account.lz[each.value.service_account_resource].member
}
