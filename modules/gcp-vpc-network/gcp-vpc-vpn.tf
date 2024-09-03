#
# Cloud VPN
#

locals {
  google_compute_vpn_tunnel           = google_compute_vpn_tunnel.lz
  google_compute_vpn_gateway          = google_compute_vpn_gateway.lz
  google_compute_external_vpn_gateway = google_compute_external_vpn_gateway.lz
}

#

resource "google_compute_ha_vpn_gateway" "lz" {
  #
  # HA VPN Gateways
  #
  for_each = {
    for gateway in local.gcp_ha_vpn_gateway : gateway.resource_index => gateway
  }

  name    = each.value.name
  network = lookup(local.google_compute_network, each.value.network, null) == null ? each.value.network : local.google_compute_network[each.value.network].id

  description = each.value.description
  stack_type  = each.value.stack_type
  region      = each.value.region
  project     = each.value.project

  dynamic "vpn_interfaces" {
    # (Optional) A list of interfaces on this VPN gateway.
    for_each = coalesce(each.value.vpn_interfaces, [])

    content {
      id                      = vpn_interfaces.value.id
      ip_address              = vpn_interfaces.value.ip_address
      interconnect_attachment = lookup(local.google_compute_interconnect_attachment, each.value.interconnect_attachment, null) == null ? each.value.interconnect_attachment : local.google_compute_interconnect_attachment[each.value.interconnect_attachment].self_link
    }
  }

  depends_on = [
    google_compute_interconnect_attachment.lz,
    google_compute_network.lz,
  ]
}

#

resource "google_compute_vpn_tunnel" "lz" {
  #
  # VPC Tunnels
  #
  for_each = {
    for tunnel in local.gcp_vpn_tunnel : tunnel.resource_index => tunnel
  }

  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  project     = each.value.project
  labels      = each.value.labels

  shared_secret = each.value.shared_secret

  target_vpn_gateway              = each.value.target_vpn_gateway == null ? null : lookup(local.google_compute_vpn_gateway, each.value.target_vpn_gateway, null) == null ? each.value.target_vpn_gateway : local.google_compute_vpn_gateway[each.value.target_vpn_gateway].self_link
  vpn_gateway                     = each.value.vpn_gateway == null ? null : lookup(local.google_compute_vpn_gateway, each.value.vpn_gateway, null) == null ? each.value.vpn_gateway : local.google_compute_vpn_gateway[each.value.vpn_gateway].self_link
  vpn_gateway_interface           = each.value.vpn_gateway_interface
  peer_external_gateway           = each.value.peer_external_gateway
  peer_external_gateway_interface = each.value.peer_external_gateway_interface
  peer_gcp_gateway                = each.value.peer_gcp_gateway
  router                          = each.value.router == null ? null : lookup(local.google_compute_router, each.value.router, null) == null ? each.value.router : local.google_compute_router[each.value.router].self_link
  peer_ip                         = each.value.peer_ip
  ike_version                     = each.value.ike_version
  local_traffic_selector          = each.value.local_traffic_selector
  remote_traffic_selector         = each.value.remote_traffic_selector

  depends_on = [
    google_compute_vpn_gateway.lz,
    google_compute_external_vpn_gateway.lz,
    google_compute_router.lz,
  ]
}

resource "google_compute_vpn_gateway" "lz" {
  #
  # Classic VPC Gateways (depreciated)
  #
  for_each = {
    for gateway in local.gcp_vpn_gateway : gateway.resource_index => gateway
  }

  name        = each.value.name
  network     = each.value.network
  description = each.value.description
  region      = each.value.region
  project     = each.value.project
}

resource "google_compute_external_vpn_gateway" "lz" {
  #
  # External VPC Gateways
  #
  for_each = {
    for gateway in local.gcp_vpn_external_gateway : gateway.resource_index => gateway
  }

  name            = each.value.name
  description     = each.value.description
  labels          = each.value.labels
  redundancy_type = each.value.redundancy_type
  project         = each.value.project

  dynamic "interface" {
    # (Optional) A list of interfaces on this external VPN gateway.
    for_each = coalesce(each.value.interface, [])

    content {
      id         = interface.value.id
      ip_address = lookup(local.google_compute_address, interface.value.ip_address, null) == null ? interface.value.ip_address : local.google_compute_address[interface.value.ip_address].address
    }
  }
}

