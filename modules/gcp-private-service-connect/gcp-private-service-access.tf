#
# Private Service Access
#

resource "google_compute_global_address" "psa" {
  #
  # Global GCP Compute Addresses for PSA
  #
  for_each = {
    for address in local.gcp_psa_address : address.resource_index => address
  }

  name        = each.value.name
  description = try(each.value.description, null)
  project     = try(each.value.project, null)

  address       = try(each.value.address, null)
  address_type  = try(each.value.address_type, null)
  purpose       = try(each.value.purpose, null)
  network       = try(each.value.network, null)
  prefix_length = try(each.value.prefix_length, null)
  ip_version    = try(each.value.ip_version, null)
}

resource "google_service_networking_connection" "psa" {
  for_each = {
    for network in local.gcp_psa_network : network.resource_index => network
  }

  network = each.value.network
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    for psa_address in each.value.address : google_compute_global_address.psa[join("_", [each.key, psa_address.name])].name
  ]
}
