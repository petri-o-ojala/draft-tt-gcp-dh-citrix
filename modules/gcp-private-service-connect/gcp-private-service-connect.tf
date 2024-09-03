#
# GCP Private Service Connect resources
#

locals {
  google_compute_address = google_compute_address.psc
}

#

resource "google_compute_address" "psc" {
  #
  # Regional GCP Compute Addresses for PSC
  #
  for_each = {
    for compute_address in local.gcp_psc_address : compute_address.resource_index => compute_address
    if try(compute_address.region, null) != null
  }

  name        = each.value.name
  description = try(each.value.description, null)
  region      = try(each.value.region, null)
  project     = try(each.value.project, null)

  address            = try(each.value.address, null)
  address_type       = try(each.value.address_type, null)
  purpose            = try(each.value.purpose, null)
  network_tier       = try(each.value.network_tier, null)
  subnetwork         = try(each.value.subnetwork, null)
  labels             = try(each.value.labels, null)
  network            = try(each.value.network, null)
  prefix_length      = try(each.value.prefix_length, null)
  ip_version         = try(each.value.ip_version, null)
  ipv6_endpoint_type = try(each.value.ipv6_endpoint_type, null)
}

