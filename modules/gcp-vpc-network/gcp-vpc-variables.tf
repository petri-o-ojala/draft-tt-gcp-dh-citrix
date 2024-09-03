#
# GCP Organization Policy assignments
#

variable "alias" {
  description = "Network and port aliases"
  type = object({
    network = optional(map(string))
    port    = optional(map(string))
  })
  default = {}
}

variable "vpc" {
  description = "GCP Networking configurations"
  type = object(
    {
      address = optional(map(object({
        name               = string
        description        = optional(string)
        region             = optional(string)
        project            = optional(string)
        address            = optional(string)
        address_type       = optional(string)
        purpose            = optional(string)
        network_tier       = optional(string)
        subnetwork         = optional(string)
        labels             = optional(map(string))
        network            = optional(string)
        prefix_length      = optional(number)
        ip_version         = optional(string)
        ipv6_endpoint_type = optional(string)
        dns = optional(object({
          name            = string
          type            = optional(string, "A")
          ttl             = optional(number, 300)
          managed_zone    = string
          project         = optional(string)
          rr_data_address = optional(bool)
          rr_data         = optional(list(string))
        }))
      })))
      interconnect_attachment = optional(map(object({
        name                     = string
        router                   = string
        admin_enabled            = optional(string)
        interconnect             = optional(string)
        description              = optional(string)
        mtu                      = optional(number)
        bandwidth                = optional(string)
        edge_availability_domain = optional(string)
        type                     = optional(string)
        candidate_subnets        = optional(list(string))
        vlan_tag8021q            = optional(string)
        ipsec_internal_addresses = optional(list(string))
        encryption               = optional(string)
        region                   = optional(string)
        project                  = optional(string)
      })))
      vpn_tunnel = optional(map(object({
        name                            = string
        shared_secret                   = string
        description                     = optional(string)
        region                          = optional(string)
        project                         = optional(string)
        labels                          = optional(map(string))
        target_vpn_gateway              = optional(string)
        router                          = optional(string)
        vpn_gateway                     = optional(string)
        vpn_gateway_interface           = optional(string)
        peer_external_gateway           = optional(string)
        peer_external_gateway_interface = optional(string)
        peer_gcp_gateway                = optional(string)
        peer_ip                         = optional(string)
        ike_version                     = optional(string)
        local_traffic_selector          = optional(list(string))
        remote_traffic_selector         = optional(list(string))
      })))
      vpn_gateway = optional(map(object({
        name        = string
        network     = string
        description = optional(string)
        region      = optional(string)
        project     = optional(string)
      })))
      ha_vpn_gateway = optional(map(object({
        name        = string
        network     = string
        description = optional(string)
        stack_type  = optional(string)
        vpn_interfaces = optional(list(object({
          id                      = optional(string)
          ip_address              = optional(string)
          interconnect_attachment = optional(string)
        })))
        region  = optional(string)
        project = optional(string)
      })))
      external_vpn_gateway = optional(map(object({
        name            = string
        description     = optional(string)
        project         = optional(string)
        labels          = optional(map(string))
        redundancy_type = optional(string)
        interface = optional(list(object({
          id         = optional(string)
          ip_address = optional(string)
        })))
      })))
      forwarding_rule = optional(map(object({
        name                    = string
        project                 = optional(string)
        is_mirroring_collector  = optional(bool)
        description             = optional(string)
        ip_address              = optional(string)
        ip_protocol             = optional(string)
        backend_service         = optional(string)
        load_balancing_scheme   = optional(string)
        network                 = optional(string)
        port_range              = optional(string)
        ports                   = optional(list(string))
        subnetwork              = optional(string)
        target                  = optional(string)
        allow_global_access     = optional(bool)
        labels                  = optional(map(string))
        all_ports               = optional(bool)
        network_tier            = optional(string)
        service_label           = optional(string)
        source_ip_ranges        = optional(list(string))
        allow_psc_global_access = optional(bool)
        no_automate_dns_zone    = optional(bool)
        ip_version              = optional(string)
        region                  = optional(string)
        recreate_closed_psc     = optional(string)
        service_directory_registrations = optional(object({
          namespace = optional(string)
          service   = optional(string)
        }))
        metadata_filters = optional(object({
          filter_match_criteria = optional(string)
          filter_labels = optional(list(object({
            name  = optional(string)
            value = optional(string)
          })))
        }))
      })))
      network = optional(map(object({
        name                                      = string
        description                               = optional(string)
        project                                   = optional(string)
        auto_create_subnetworks                   = optional(bool)
        routing_mode                              = optional(string)
        mtu                                       = optional(number)
        enable_ula_internal_ipv6                  = optional(bool)
        internal_ipv6_range                       = optional(string)
        network_firewall_policy_enforcement_order = optional(string)
        delete_default_routes_on_create           = optional(bool)
        route = optional(list(object({
          name                   = string
          dest_range             = string
          network                = string
          project                = optional(string)
          description            = optional(string)
          priority               = optional(number)
          tags                   = optional(list(string))
          next_hop_gateway       = optional(string)
          next_hop_instance      = optional(string)
          next_hop_ip            = optional(string)
          next_hop_ilb           = optional(string)
          next_hop_instance_zone = optional(string)
        })))
        firewall_rule = optional(map(object({
          name                    = optional(string)
          project                 = optional(string)
          network                 = optional(string)
          description             = optional(string)
          destination_ranges      = optional(list(string))
          direction               = optional(string)
          disabled                = optional(bool)
          priority                = optional(number)
          source_ranges           = optional(list(string))
          source_service_accounts = optional(list(string))
          source_tags             = optional(list(string))
          target_service_accounts = optional(list(string))
          target_tags             = optional(list(string))
          enable_logging          = optional(bool)
          log_config = optional(object({
            metadata = string
          }))
          allow = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })))
          deny = optional(list(object({
            protocol = string
            ports    = optional(list(string))
          })))
        })))
        subnet = optional(map(object({
          name                       = string
          ip_cidr_range              = string
          network                    = optional(string)
          region                     = optional(string)
          project                    = optional(string)
          description                = optional(string)
          purpose                    = optional(string)
          role                       = optional(string)
          private_ip_google_access   = optional(bool)
          private_ipv6_google_access = optional(bool)
          stack_type                 = optional(string)
          ipv6_access_type           = optional(string)
          external_ipv6_prefix       = optional(string)
          secondary_ip_range = optional(list(object({
            range_name    = string
            ip_cidr_range = string
          })))
          log_config = optional(object({
            aggregation_interval = optional(string)
            flow_sampling        = optional(string)
            metadata             = optional(string)
            metadata_fields      = optional(string)
            filter_expr          = optional(string)
          }))
          iam = optional(list(object({
            role    = optional(string)
            member  = optional(list(string))
            project = optional(string)
            condition = optional(object({
              expression  = string
              title       = string
              description = optional(string)
            }))
          })))
        })))
      })))
      router = optional(map(object({
        name                          = string
        network                       = optional(string)
        description                   = optional(string)
        encrypted_interconnect_router = optional(string)
        region                        = optional(string)
        project                       = optional(string)
        bgp = optional(object({
          asn                = optional(string)
          advertise_mode     = optional(string)
          advertised_groups  = optional(list(string))
          keepalive_interval = optional(number)
          advertised_ip_ranges = optional(list(object({
            range       = optional(string)
            description = optional(string)
          })))
        }))
      })))
      router_interface = optional(map(object({
        name                    = string
        router                  = string
        ip_range                = optional(string)
        vpn_tunnel              = optional(string)
        interconnect_attachment = optional(string)
        redundant_interface     = optional(string)
        project                 = optional(string)
        subnetwork              = optional(string)
        private_ip_address      = optional(string)
        region                  = optional(string)
      })))
      router_peer = optional(map(object({
        name                      = string
        interface                 = string
        peer_asn                  = number
        router                    = string
        ip_address                = optional(string)
        peer_ip_address           = optional(string)
        advertised_route_priority = optional(number)
        advertise_mode            = optional(string)
        advertised_groups         = optional(list(string))
        enable                    = optional(bool)
        router_appliance_instance = optional(string)
        enable_ipv6               = optional(bool)
        ipv6_nexthop_address      = optional(string)
        peer_ipv6_nexthop_address = optional(string)
        region                    = optional(string)
        project                   = optional(string)
        advertised_ip_ranges = optional(list(object({
          range       = string
          description = optional(string)
        })))
        bfd = optional(object({
          session_initialization_mode = optional(string)
          min_transmit_interval       = optional(number)
          min_receive_interval        = optional(number)
          multiplier                  = optional(number)
        }))
      })))
      nat = optional(map(object({
        name                                = string
        source_subnetwork_ip_ranges_to_nat  = optional(string)
        router                              = optional(string)
        nat_ip_allocate_option              = optional(string)
        nat_ips                             = optional(list(string))
        drain_nat_ips                       = optional(list(string))
        min_ports_per_vm                    = optional(number)
        max_ports_per_vm                    = optional(number)
        enable_dynamic_port_allocation      = optional(bool)
        udp_idle_timeout_sec                = optional(number)
        icmp_idle_timeout_sec               = optional(number)
        tcp_established_idle_timeout_sec    = optional(number)
        tcp_transitory_idle_timeout_sec     = optional(number)
        tcp_time_wait_timeout_sec           = optional(number)
        enable_endpoint_independent_mapping = optional(bool)
        type                                = optional(string)
        region                              = optional(string)
        project                             = optional(string)
        subnetwork = optional(list(object({
          name                     = optional(string)
          source_ip_ranges_to_nat  = optional(list(string))
          secondary_ip_range_names = optional(list(string))
        })))
        log_config = optional(object({
          enable = optional(bool)
          filter = optional(string)
        }))
        rules = optional(list(object({
          rule_number = optional(number)
          description = optional(string)
          match       = optional(string)
          action = optional(object({
            source_nat_active_ips    = optional(list(string))
            source_nat_drain_ips     = optional(list(string))
            source_nat_active_ranges = optional(list(string))
            source_nat_drain_ranges  = optional(list(string))
          }))
        })))
      })))
      /*
      address = optional(map(object({
        name               = string
        description        = optional(string)
        region             = optional(string)
        project            = optional(string)
        address            = optional(string)
        address_type       = optional(string)
        purpose            = optional(string)
        network_tier       = optional(string)
        subnetwork         = optional(string)
        labels             = optional(map(string))
        network            = optional(string)
        prefix_length      = optional(number)
        ip_version         = optional(string)
        ipv6_endpoint_type = optional(string)
      })))
*/
      shared_network = optional(map(object({
        project                 = string
        service_project         = optional(list(string))
        deletion_policy         = optional(map(string))
        default_deletion_policy = optional(string)
      })))
      peering = optional(map(object({
        name                                = string
        network                             = string
        peer_network                        = string
        export_custom_routes                = optional(bool)
        import_custom_routes                = optional(bool)
        export_subnet_routes_with_public_ip = optional(bool)
        import_subnet_routes_with_public_ip = optional(bool)
        stack_type                          = optional(string)
      })))
    }
  )
  default = {}
}

variable "vpc_json_configuration_file" {
  description = "JSON configuration file for vpcs"
  type        = string
  default     = "gcp-vpc.json"
}

variable "vpc_yaml_configuration_file" {
  description = "YAML configuration file for vpcs"
  type        = string
  default     = "gcp-vpc.yaml"
}


locals {
  #
  # Support for JSON, YAML and variable configuration
  #
  vpc_json_configuration = fileexists("${path.root}/${var.vpc_json_configuration_file}") ? jsondecode(file("${path.root}/${var.vpc_json_configuration_file}")) : {}
  vpc_yaml_configuration = fileexists("${path.root}/${var.vpc_yaml_configuration_file}") ? yamldecode(file("${path.root}/${var.vpc_yaml_configuration_file}")) : {}

  vpc = merge(
    var.vpc,
    try(local.vpc_json_configuration.project, {}),
    try(local.vpc_yaml_configuration.project, {}),
  )
  vpc_forwarding_rule = merge(
    coalesce(try(var.vpc.forwarding_rule, {}), {}),
    try(local.vpc_json_configuration.vpc.forwarding_rule, {}),
    try(local.vpc_yaml_configuration.vpc.forwarding_rule, {}),
  )
  interconnect_attachment = merge(
    coalesce(try(var.vpc.interconnect_attachment, {}), {}),
    try(local.vpc_json_configuration.vpc.interconnect_attachment, {}),
    try(local.vpc_yaml_configuration.vpc.interconnect_attachment, {}),
  )
  vpn_tunnel = merge(
    coalesce(try(var.vpc.vpn_tunnel, {}), {}),
    try(local.vpc_json_configuration.vpc.vpn_tunnel, {}),
    try(local.vpc_yaml_configuration.vpc.vpn_tunnel, {}),
  )
  vpn_external_gateway = merge(
    coalesce(try(var.vpc.external_vpn_gateway, {}), {}),
    try(local.vpc_json_configuration.vpc.external_vpn_gateway, {}),
    try(local.vpc_yaml_configuration.vpc.external_vpn_gateway, {}),
  )
  ha_vpn_gateway = merge(
    coalesce(try(var.vpc.ha_vpn_gateway, {}), {}),
    try(local.vpc_json_configuration.vpc.ha_vpn_gateway, {}),
    try(local.vpc_yaml_configuration.vpc.ha_vpn_gateway, {}),
  )
  vpn_gateway = merge(
    coalesce(try(var.vpc.vpn_gateway, {}), {}),
    try(local.vpc_json_configuration.vpc.vpn_gateway, {}),
    try(local.vpc_yaml_configuration.vpc.vpn_gateway, {}),
  )
  vpc_compute_address = merge(
    coalesce(try(var.vpc.address, {}), {}),
    try(local.vpc_json_configuration.vpc.address, {}),
    try(local.vpc_yaml_configuration.vpc.address, {}),
  )
  vpc_peering = merge(
    coalesce(try(var.vpc.peering, {}), {}),
    try(local.vpc_json_configuration.vpc.peering, {}),
    try(local.vpc_yaml_configuration.vpc.peering, {}),
  )

  network_alias = merge(
    var.alias.network,
    try(local.vpc_json_configuration.alias.network, {}),
    try(local.vpc_yaml_configuration.alias.network, {}),
  )

  port_alias = merge(
    var.alias.port,
    try(local.vpc_json_configuration.alias.port, {}),
    try(local.vpc_yaml_configuration.alias.port, {}),
  )

  #
  # GCP VPCs
  #
  gcp_vpc = flatten([
    for vpc_id, vpc in try(local.vpc.network, {}) : merge(
      vpc,
      {
        resource_index = join("_", [vpc_id])
      }
    )
  ])

  #
  # GCP VPC routes
  #
  gcp_vpc_route = flatten([
    for vpc_id, vpc in try(local.vpc.network, {}) : [
      for route in coalesce(try(vpc.route, null), []) : merge(
        route,
        {
          resource_index = join("_", [vpc_id, route.name])
        }
      )
    ]
  ])

  #
  # GCP VPC Address allocations
  #
  gcp_vpc_compute_address = flatten([
    for address_id, address in coalesce(try(local.vpc_compute_address, null), {}) : merge(
      address,
      {
        resource_index = join("_", [address_id])
      }
    )
  ])

  #
  # GCP VPC Subnets
  #
  gcp_vpc_subnet = flatten([
    for vpc_id, vpc in try(local.vpc.network, {}) : [
      for subnet_id, subnet in coalesce(try(vpc.subnet, null), {}) : merge(
        subnet,
        {
          network        = coalesce(subnet.network, google_compute_network.lz[vpc_id].name)
          resource_index = join("_", [vpc_id, subnet_id])
        }
      )
    ]
  ])

  #
  # GCP VPC Firewall rules
  #

  gcp_vpc_firewall_rule = flatten([
    for vpc_id, vpc in try(local.vpc.network, {}) : [
      for firewall_rule_id, firewall_rule in coalesce(vpc.firewall_rule, {}) : merge(
        firewall_rule,
        {
          name           = coalesce(firewall_rule.name, firewall_rule_id)
          network        = coalesce(firewall_rule.network, google_compute_network.lz[vpc_id].name)
          project        = coalesce(firewall_rule.project, google_compute_network.lz[vpc_id].project)
          resource_index = join("_", [vpc_id, coalesce(firewall_rule.name, firewall_rule_id)])
        }
      )
    ]
  ])

  #
  # GCP VPC Subnet IAM roles
  #
  gcp_vpc_subnet_iam = flatten([
    for vpc_id, vpc in try(local.vpc.network, {}) : [
      for subnet_id, subnet in coalesce(vpc.subnet, {}) : [
        for iam in coalesce(try(subnet.iam, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            member         = member
            role           = iam.role
            condition      = iam.condition
            project        = coalesce(subnet.project, google_compute_subnetwork.lz[join("_", [vpc_id, subnet_id])].project)
            subnetwork     = coalesce(subnet.network, google_compute_subnetwork.lz[join("_", [vpc_id, subnet_id])].name)
            region         = coalesce(subnet.region, google_compute_subnetwork.lz[join("_", [vpc_id, subnet_id])].region)
            resource_index = join("_", [vpc_id, subnet_id, iam.role, member])
          }
        ]
      ]
    ]
  ])

  #
  # GCP Shared VPC host projects
  #
  gcp_shared_vpc_host = flatten([
    for shared_vpc_id, shared_vpc in coalesce(local.vpc.shared_network, {}) : {
      project        = shared_vpc.project
      resource_index = join("_", [shared_vpc_id, shared_vpc.project])
    }
  ])

  #
  # GCP Shared VPC service projects
  #
  gcp_shared_vpc_service = flatten([
    for shared_vpc_id, shared_vpc in coalesce(local.vpc.shared_network, {}) : [
      for service_project in coalesce(try(shared_vpc.service_project, null), []) : merge(
        {
          host_project    = try(shared_vpc.project, null)
          service_project = service_project
          deletion_policy = try(shared_vpc.deletion_policy[service_project], try(shared_vpc.default_deletion_policy, null))
          resource_index  = join("_", [shared_vpc_id, shared_vpc.project, service_project])
        }
      )
      if try(shared_vpc.service_project, null) != null
    ]
  ])

  #
  # Cloud VPN
  #

  gcp_ha_vpn_gateway = flatten([
    for gateway_id, gateway in coalesce(try(local.ha_vpn_gateway, null), {}) : merge(
      gateway,
      {
        resource_index = join("_", [gateway_id])
      }
    )
  ])

  gcp_vpn_tunnel = flatten([
    for tunnel_id, tunnel in coalesce(try(local.vpn_tunnel, null), {}) : merge(
      tunnel,
      {
        resource_index = join("_", [tunnel_id])
      }
    )
  ])

  gcp_vpn_gateway = flatten([
    for gateway_id, gateway in coalesce(try(local.vpn_gateway, null), {}) : merge(
      gateway,
      {
        resource_index = join("_", [gateway_id])
      }
    )
  ])

  gcp_vpn_external_gateway = flatten([
    for gateway_id, gateway in coalesce(try(local.vpn_external_gateway, null), {}) : merge(
      gateway,
      {
        resource_index = join("_", [gateway_id])
      }
    )
  ])

  gcp_vpc_forwarding_rule = flatten([
    for rule_id, rule in coalesce(try(local.vpc_forwarding_rule, null), {}) : merge(
      rule,
      {
        resource_index = join("_", [rule_id])
      }
    )
  ])

  #
  # Cloud Interconnect
  #
  gcp_interconnect_attachment = flatten([
    for attachment_id, attachment in coalesce(try(local.interconnect_attachment, null), {}) : merge(
      attachment,
      {
        resource_index = join("_", [attachment_id])
      }
    )
  ])

  #
  # VPC Peerings
  #
  gcp_vpc_peering = flatten([
    for peering_id, peering in coalesce(try(local.vpc_peering, null), {}) : merge(
      peering,
      {
        resource_index = join("_", [peering_id])
      }
    )
  ])
}
