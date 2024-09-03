#
# IAP IAM permissions for Compute Instances
#

resource "google_project_iam_member" "iap_instance_project" {
  #
  # GCE Visibility through compute.viewer for IAP users
  #
  for_each = {
    for iap_access in local.compute_instance_iap_permission : iap_access.resource_index => iap_access
    if try(iap_access.scope, null) == "project"
  }

  project = each.value.project
  role    = each.value.role
  member  = each.value.member
}

resource "google_compute_instance_iam_member" "iap_instance" {
  for_each = {
    for iap_access in local.compute_instance_iap_permission : iap_access.resource_index => iap_access
    if try(iap_access.scope, null) == "instance"
  }

  project       = each.value.project
  instance_name = google_compute_instance.lz[each.value.instance].name
  zone          = google_compute_instance.lz[each.value.instance].zone
  role          = each.value.role
  member        = each.value.member
}

resource "google_iap_tunnel_instance_iam_member" "iap_instance" {
  for_each = {
    for iap_access in local.compute_instance_iap_permission : iap_access.resource_index => iap_access
    if try(iap_access.scope, null) == "iap_tunnel_instance"
  }

  project  = each.value.project
  instance = google_compute_instance.lz[each.value.instance].name
  zone     = google_compute_instance.lz[each.value.instance].zone
  role     = each.value.role
  member   = each.value.member
}

resource "google_service_account_iam_member" "iap" {
  for_each = {
    for iap_access in local.compute_instance_iap_permission : iap_access.resource_index => iap_access
    if try(iap_access.scope, null) == "service_account"
  }

  service_account_id = lookup(local.compute_service_account, each.value.service_account, null) == null ? each.value.service_account : google_service_account.compute[each.value.service_account].name
  role               = each.value.role
  member             = each.value.member

  depends_on = [
    google_service_account.compute
  ]
}
