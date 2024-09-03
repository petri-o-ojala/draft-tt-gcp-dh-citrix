#
# GCP Compute Engine network resources
#

resource "google_compute_address" "lz" {
  #
  # Regional Compute Addresses
  #
  for_each = {
    for compute_address in local.gcp_compute_address : compute_address.resource_index => compute_address
    if compute_address.region != null
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

resource "google_compute_global_address" "lz" {
  #
  # Global Compute Addresses
  #
  for_each = {
    for address in local.gcp_compute_address : address.resource_index => address
    if address.region == null
  }

  provider = google-beta

  name        = each.value.name
  description = try(each.value.description, null)
  project     = try(each.value.project, null)

  address       = try(each.value.address, null)
  address_type  = try(each.value.address_type, null)
  purpose       = try(each.value.purpose, null)
  labels        = try(each.value.labels, null)
  network       = try(each.value.network, null)
  prefix_length = try(each.value.prefix_length, null)
  ip_version    = try(each.value.ip_version, null)
}

locals {
  #
  # A variable with all the Compute Addresses for easy lookup
  #
  google_compute_address = merge(
    google_compute_address.lz,
    google_compute_global_address.lz,
  )
}
