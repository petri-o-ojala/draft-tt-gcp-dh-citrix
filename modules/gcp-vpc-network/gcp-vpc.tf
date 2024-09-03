#
# GCP VPC resources
#

locals {
  google_compute_network    = google_compute_network.lz
  google_compute_subnetwork = google_compute_subnetwork.lz
}

#

resource "google_compute_network" "lz" {
  #
  # VPC networks
  #
  for_each = {
    for vpc in local.gcp_vpc : vpc.resource_index => vpc
  }

  name        = each.value.name
  description = each.value.description
  project     = each.value.project

  auto_create_subnetworks                   = each.value.auto_create_subnetworks
  routing_mode                              = each.value.routing_mode
  mtu                                       = each.value.mtu
  enable_ula_internal_ipv6                  = each.value.enable_ula_internal_ipv6
  internal_ipv6_range                       = each.value.internal_ipv6_range
  network_firewall_policy_enforcement_order = each.value.network_firewall_policy_enforcement_order
  delete_default_routes_on_create           = each.value.delete_default_routes_on_create
}

resource "google_compute_route" "lz" {
  #
  # VPC routes
  #
  for_each = {
    for route in local.gcp_vpc_route : route.resource_index => route
  }

  name       = each.value.name
  dest_range = each.value.dest_range
  network    = each.value.network

  description            = try(each.value.description, null)
  project                = try(each.value.project, null)
  priority               = try(each.value.priority, null)
  tags                   = try(each.value.tags, null)
  next_hop_gateway       = try(each.value.next_hop_gateway, null)
  next_hop_instance      = try(each.value.next_hop_instance, null)
  next_hop_ip            = try(each.value.next_hop_ip, null)
  next_hop_ilb           = try(each.value.next_hop_ilb, null)
  next_hop_instance_zone = try(each.value.next_hop_instance_zone, null)
}

resource "google_compute_subnetwork" "lz" {
  #
  # VPC Subnets
  #
  for_each = {
    for subnet in local.gcp_vpc_subnet : subnet.resource_index => subnet
  }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  network       = each.value.network
  region        = try(each.value.region, null)
  project       = try(each.value.project, null)

  description                = try(each.value.description, null)
  purpose                    = try(each.value.purpose, null)
  role                       = try(each.value.role, null)
  private_ip_google_access   = try(each.value.private_ip_google_access, null)
  private_ipv6_google_access = try(each.value.private_ipv6_google_access, null)
  stack_type                 = try(each.value.stack_type, null)
  ipv6_access_type           = try(each.value.ipv6_access_type, null)
  external_ipv6_prefix       = try(each.value.external_ipv6_prefix, null)
  # allow_subnet_cidr_routes_overlap = try(each.value.allow_subnet_cidr_routes_overlap, null)

  dynamic "secondary_ip_range" {
    # (Optional) An array of configurations for secondary IP ranges for VM instances contained in 
    # this subnetwork. The primary IP of such VM must belong to the primary ipCidrRange of the
    # subnetwork. The alias IPs may belong to either primary or secondary ranges
    for_each = coalesce(each.value.secondary_ip_range, [])

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  dynamic "log_config" {
    # (Optional) This field denotes the VPC flow logging options for this subnetwork. If logging is 
    # enabled, logs are exported to Cloud Logging. Flow logging isn't supported if the subnet
    # purpose field is set to subnetwork is REGIONAL_MANAGED_PROXY or GLOBAL_MANAGED_PROXY.
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      aggregation_interval = try(each.value.log_config.aggregation_interval, null)
      flow_sampling        = try(each.value.log_config.flow_sampling, null)
      metadata             = try(each.value.log_config.metadata, null)
      metadata_fields      = try(each.value.log_config.metadata_fields, null)
      filter_expr          = try(each.value.log_config.filter_expr, null)
    }
  }
}

resource "google_compute_subnetwork_iam_member" "lz" {
  #
  # GCP Subnets IAM
  #
  for_each = {
    for iam in local.gcp_vpc_subnet_iam : iam.resource_index => iam
  }

  subnetwork = each.value.subnetwork

  region  = try(each.value.region, null)
  project = try(each.value.project, null)
  role    = each.value.role
  member  = each.value.member

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
