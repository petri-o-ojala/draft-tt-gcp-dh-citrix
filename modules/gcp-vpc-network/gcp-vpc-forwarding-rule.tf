#
# VPC Forwarding rules
#

resource "google_compute_forwarding_rule" "vpc" {
  #
  # VPC Forwarding Rules (Regional)
  #
  for_each = {
    for rule in local.gcp_vpc_forwarding_rule : rule.resource_index => rule
    if rule.region != null
  }

  provider = google-beta

  name                    = each.value.name
  project                 = each.value.project
  is_mirroring_collector  = each.value.is_mirroring_collector
  description             = each.value.description
  ip_address              = each.value.ip_address == null ? null : lookup(local.google_compute_address, each.value.ip_address, null) == null ? each.value.ip_address : local.google_compute_address[each.value.ip_address].self_link
  ip_protocol             = each.value.ip_protocol
  backend_service         = each.value.backend_service
  load_balancing_scheme   = each.value.load_balancing_scheme
  network                 = each.value.network
  port_range              = each.value.port_range
  ports                   = each.value.ports
  subnetwork              = each.value.subnetwork
  target                  = each.value.target == null ? null : lookup(local.google_compute_vpn_gateway, each.value.target, null) == null ? each.value.target : local.google_compute_vpn_gateway[each.value.target].id
  allow_global_access     = each.value.allow_global_access
  labels                  = each.value.labels
  all_ports               = each.value.all_ports
  network_tier            = each.value.network_tier
  service_label           = each.value.service_label
  source_ip_ranges        = each.value.source_ip_ranges
  allow_psc_global_access = each.value.allow_psc_global_access
  no_automate_dns_zone    = each.value.no_automate_dns_zone
  ip_version              = each.value.ip_version
  region                  = each.value.region
  recreate_closed_psc     = each.value.recreate_closed_psc

  dynamic "service_directory_registrations" {
    for_each = try(each.value.service_directory_registrations, null) == null ? [] : [1]

    content {
      namespace = each.value.service_directory_registrations.namespace
      service   = each.value.service_directory_registrations.service
    }
  }
}

resource "google_compute_global_forwarding_rule" "vpc" {
  #
  # VPC Forwarding Rules (Global)
  #
  for_each = {
    for rule in local.gcp_vpc_forwarding_rule : rule.resource_index => rule
    if rule.region == null
  }

  provider = google-beta

  name                    = each.value.name
  project                 = each.value.project
  target                  = each.value.target == null ? null : lookup(local.google_compute_vpn_gateway, each.value.target, null) == null ? each.value.target : local.google_compute_vpn_gateway[each.value.target].id
  description             = each.value.description
  ip_address              = each.value.ip_address == null ? null : lookup(local.google_compute_address, each.value.ip_address, null) == null ? each.value.ip_address : local.google_compute_address[each.value.ip_address].self_link
  ip_protocol             = each.value.ip_protocol
  ip_version              = each.value.ip_version
  load_balancing_scheme   = each.value.load_balancing_scheme
  network                 = each.value.network
  port_range              = each.value.port_range
  subnetwork              = each.value.subnetwork
  labels                  = each.value.labels
  source_ip_ranges        = each.value.source_ip_ranges
  allow_psc_global_access = each.value.allow_psc_global_access
  no_automate_dns_zone    = each.value.no_automate_dns_zone

  dynamic "metadata_filters" {
    # (Optional) Opaque filter criteria used by Loadbalancer to restrict routing configuration to a limited set xDS compliant clients. In their xDS requests to Loadbalancer, xDS clients present node metadata. If a match takes place, the relevant routing configuration is made available to those proxies. For each metadataFilter in this list, if its filterMatchCriteria is set to MATCH_ANY, at least one of the filterLabels must match the corresponding label provided in the metadata. If its filterMatchCriteria is set to MATCH_ALL, then all of its filterLabels must match with corresponding labels in the provided metadata. metadataFilters specified here can be overridden by those specified in the UrlMap that this ForwardingRule references. metadataFilters only applies to Loadbalancers that have their loadBalancingScheme set to INTERNAL_SELF_MANAGED. 
    for_each = try(each.value.metadata_filters, null) == null ? [] : [1]

    content {
      filter_match_criteria = each.value.metadata_filters.filter_match_criteria

      dynamic "filter_labels" {
        # 
        for_each = coalesce(each.value.metadata_filters.filter_labels, [])

        content {
          name  = filter_labels.value.name
          value = filter_labels.value.value
        }
      }
    }
  }

  dynamic "service_directory_registrations" {
    for_each = try(each.value.service_directory_registrations, null) == null ? [] : [1]

    content {
      namespace                = each.value.service_directory_registrations.namespace
      service_directory_region = each.value.service_directory_registrations.service_directory_region
    }
  }
}

locals {
  #
  # A variable with all the Forwarding Rules for easy lookup
  #
  google_compute_forwarding_rule = merge(
    google_compute_forwarding_rule.vpc,
    google_compute_global_forwarding_rule.vpc,
  )
}

