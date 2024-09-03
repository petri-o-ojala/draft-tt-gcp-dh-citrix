#
# VPC Peerings
#

resource "google_compute_network_peering" "lz" {
  #
  # VPC Peerings
  #
  for_each = {
    for peering in local.gcp_vpc_peering : peering.resource_index => peering
  }

  name         = each.value.name
  network      = each.value.network == null ? null : lookup(local.google_compute_network, each.value.network, null) == null ? each.value.network : local.google_compute_network[each.value.network].self_link
  peer_network = each.value.peer_network == null ? null : lookup(local.google_compute_network, each.value.peer_network, null) == null ? each.value.peer_network : local.google_compute_network[each.value.peer_network].self_link

  export_custom_routes                = each.value.export_custom_routes
  import_custom_routes                = each.value.import_custom_routes
  export_subnet_routes_with_public_ip = each.value.export_subnet_routes_with_public_ip
  import_subnet_routes_with_public_ip = each.value.import_subnet_routes_with_public_ip
  stack_type                          = each.value.stack_type

  depends_on = [
    google_compute_network.lz
  ]
}
