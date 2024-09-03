#
# GCP Cloud NAT services
#

#
# Local Variables for resources
#

locals {
  google_compute_router           = google_compute_router.lz
  google_compute_router_interface = google_compute_router_interface.lz
}

#

resource "google_compute_router" "lz" {
  for_each = {
    for router in local.gcp_cloud_router : router.resource_index => router
  }

  provider = google-beta

  name                          = each.value.name
  network                       = lookup(try(local.vpc.network, {}), each.value.network, null) == null ? each.value.network : google_compute_network.lz[each.value.network].self_link
  description                   = each.value.description
  encrypted_interconnect_router = each.value.encrypted_interconnect_router
  region                        = each.value.region
  project                       = coalesce(each.value.project, try(google_compute_network.lz[each.value.network].self_link, null))

  dynamic "bgp" {
    # (Optional) BGP information specific to this router.
    for_each = try(each.value.bgp, null) == null ? [] : [1]

    content {
      asn                = each.value.bgp.asn
      advertise_mode     = each.value.bgp.advertise_mode
      advertised_groups  = each.value.bgp.advertised_groups
      keepalive_interval = each.value.bgp.keepalive_interval

      dynamic "advertised_ip_ranges" {
        # (Optional) User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if
        # advertiseMode is CUSTOM and is advertised to all peers of the router. These IP ranges will be advertised in addition
        # to any specified groups. Leave this field blank to advertise no custom IP ranges.
        for_each = coalesce(each.value.bgp.advertised_ip_ranges, [])

        content {
          range       = advertised_ip_ranges.value.range
          description = advertised_ip_ranges.value.description
        }
      }
    }
  }
}

resource "google_compute_router_interface" "lz" {
  for_each = {
    for interface in local.gcp_router_interface : interface.resource_index => interface
  }

  name   = each.value.name
  router = lookup(local.google_compute_router, each.value.router, null) == null ? each.value.router : local.google_compute_router[each.value.router].name

  ip_range                = each.value.ip_range
  vpn_tunnel              = each.value.vpn_tunnel == null ? null : lookup(local.google_compute_vpn_tunnel, each.value.vpn_tunnel, null) == null ? each.value.vpn_tunnel : local.google_compute_vpn_tunnel[each.value.vpn_tunnel].self_link
  interconnect_attachment = each.value.interconnect_attachment == null ? null : lookup(local.google_compute_interconnect_attachment, each.value.interconnect_attachment, null) == null ? each.value.interconnect_attachment : local.google_compute_interconnect_attachment[each.value.interconnect_attachment].self_link
  redundant_interface     = each.value.redundant_interface
  project                 = each.value.project
  subnetwork              = each.value.subnetwork
  private_ip_address      = each.value.private_ip_address
  region                  = each.value.region

  depends_on = [
    google_compute_vpn_tunnel.lz,
    google_compute_interconnect_attachment.lz,
  ]
}

resource "google_compute_router_peer" "lz" {
  for_each = {
    for peer in local.gcp_router_peer : peer.resource_index => peer
  }

  name      = each.value.name
  interface = lookup(local.google_compute_router_interface, each.value.interface, null) == null ? each.value.interface : local.google_compute_router_interface[each.value.interface].name
  peer_asn  = each.value.peer_asn
  router    = lookup(local.google_compute_router, each.value.router, null) == null ? each.value.router : local.google_compute_router[each.value.router].name

  ip_address                = each.value.ip_address
  peer_ip_address           = each.value.peer_ip_address
  advertised_route_priority = each.value.advertised_route_priority
  advertise_mode            = each.value.advertise_mode
  advertised_groups         = each.value.advertised_groups
  enable                    = each.value.enable
  router_appliance_instance = each.value.router_appliance_instance
  enable_ipv6               = each.value.enable_ipv6
  ipv6_nexthop_address      = each.value.ipv6_nexthop_address
  peer_ipv6_nexthop_address = each.value.peer_ipv6_nexthop_address
  region                    = each.value.region
  project                   = each.value.project

  dynamic "advertised_ip_ranges" {
    # (Optional) User-specified list of individual IP ranges to advertise in custom mode. This field can only be populated if 
    # advertiseMode is CUSTOM and is advertised to all peers of the router. These IP ranges will be advertised in addition to
    # any specified groups. Leave this field blank to advertise no custom IP ranges. 

    for_each = coalesce(each.value.advertised_ip_ranges, [])

    content {
      range       = advertised_ip_ranges.value.range
      description = advertised_ip_ranges.value.description
    }
  }

  dynamic "bfd" {
    # (Optional) BFD configuration for the BGP peering.
    for_each = try(each.value.bfd, null) == null ? [] : [1]

    content {
      session_initialization_mode = each.value.bfd.session_initialization_mode
      min_transmit_interval       = each.value.bfd.min_transmit_interval
      min_receive_interval        = each.value.bfd.min_receive_interval
      multiplier                  = each.value.bfd.multiplier
    }
  }

  depends_on = [
    google_compute_router_interface.lz,
    google_compute_router.lz,
  ]
}

resource "google_compute_router_nat" "lz" {
  for_each = {
    for nat in local.gcp_cloud_nat : nat.resource_index => nat
  }

  provider = google-beta

  name                                = each.value.name
  source_subnetwork_ip_ranges_to_nat  = each.value.source_subnetwork_ip_ranges_to_nat
  router                              = lookup(try(local.vpc.router, {}), each.value.router, null) == null ? each.value.router : google_compute_router.lz[each.value.router].name
  nat_ip_allocate_option              = each.value.nat_ip_allocate_option
  nat_ips                             = [for ip in each.value.nat_ips : lookup(coalesce(local.google_compute_address, {}), ip) == null ? ip : local.google_compute_address[ip].self_link]
  drain_nat_ips                       = each.value.drain_nat_ips
  min_ports_per_vm                    = each.value.min_ports_per_vm
  max_ports_per_vm                    = each.value.max_ports_per_vm
  enable_dynamic_port_allocation      = each.value.enable_dynamic_port_allocation
  udp_idle_timeout_sec                = each.value.udp_idle_timeout_sec
  icmp_idle_timeout_sec               = each.value.icmp_idle_timeout_sec
  tcp_established_idle_timeout_sec    = each.value.tcp_established_idle_timeout_sec
  tcp_transitory_idle_timeout_sec     = each.value.tcp_transitory_idle_timeout_sec
  tcp_time_wait_timeout_sec           = each.value.tcp_time_wait_timeout_sec
  enable_endpoint_independent_mapping = each.value.enable_endpoint_independent_mapping
  type                                = each.value.type
  region                              = each.value.region
  project                             = coalesce(each.value.project, try(google_compute_router.lz[each.value.router].project, null))

  dynamic "subnetwork" {
    # (Optional) One or more subnetwork NAT configurations. Only used if source_subnetwork_ip_ranges_to_nat is set to LIST_OF_SUBNETWORKS
    for_each = coalesce(each.value.subnetwork, [])

    content {
      name                     = subnetwork.value.name
      source_ip_ranges_to_nat  = subnetwork.value.source_ip_ranges_to_nat
      secondary_ip_range_names = subnetwork.value.secondary_ip_range_names
    }
  }

  dynamic "log_config" {
    # (Optional) Configuration for logging on NAT
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      enable = each.value.log_config.enable
      filter = each.value.log_config.filter
    }
  }

  dynamic "rules" {
    # (Optional) A list of rules associated with this NAT.
    for_each = coalesce(each.value.rules, [])

    content {
      rule_number = rules.value.rule_number
      description = rules.value.description
      match       = rules.value.match

      dynamic "action" {
        #  (Optional) The action to be enforced for traffic that matches this rule.
        for_each = try(rules.value.action, null) == null ? [] : [1]

        content {
          source_nat_active_ips    = rules.value.action.source_nat_active_ips
          source_nat_drain_ips     = rules.value.action.source_nat_drain_ips
          source_nat_active_ranges = rules.value.action.source_nat_active_ranges
          source_nat_drain_ranges  = rules.value.action.source_nat_drain_ranges
        }
      }
    }
  }
}

/*
resource "google_compute_address" "nat" {
  #
  # GCP Compute Addresses for Cloud NAT
  #
  for_each = {
    for address in local.gcp_cloud_nat_address : address.resource_index => address
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
*/
