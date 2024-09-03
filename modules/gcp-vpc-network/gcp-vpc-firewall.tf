#
# VPC Firewall rules
#

resource "google_compute_firewall" "lz" {
  #
  # VPC Firewall rule
  #
  for_each = {
    for rule in local.gcp_vpc_firewall_rule : rule.resource_index => rule
  }

  name        = each.value.name
  network     = each.value.network
  description = try(each.value.description, null)
  project     = try(each.value.project, null)

  direction = try(each.value.direction, null)
  disabled  = try(each.value.disabled, null)
  priority  = try(each.value.priority, null)

  source_ranges           = each.value.source_ranges == null ? null : [for ip_range in each.value.source_ranges : lookup(local.network_alias, ip_range, ip_range)]
  source_service_accounts = try(each.value.source_service_accounts, null)
  source_tags             = try(each.value.source_tags, null)

  destination_ranges      = each.value.destination_ranges == null ? null : [for ip_range in each.value.destination_ranges : lookup(local.network_alias, ip_range, ip_range)]
  target_service_accounts = try(each.value.target_service_accounts, null)
  target_tags             = try(each.value.target_tags, null)

  dynamic "allow" {
    # (Optional) The list of ALLOW rules specified by this firewall. Each rule specifies a protocol and 
    # port-range tuple that describes a permitted connection.
    for_each = coalesce(each.value.allow, [])

    content {
      protocol = allow.value.protocol
      ports    = try(allow.value.ports, null) == null ? null : [for port in allow.value.ports : lookup(local.port_alias, port, port)]
    }
  }

  dynamic "deny" {
    # (Optional) The list of DENY rules specified by this firewall. Each rule specifies a protocol and
    # port-range tuple that describes a denied connection. 
    for_each = coalesce(each.value.deny, [])

    content {
      protocol = deny.value.protocol
      ports    = try(deny.value.ports, null) == null ? null : [for port in deny.value.ports : lookup(local.port_alias, port, port)]
    }
  }

  dynamic "log_config" {
    # (Optional) This field denotes the logging options for a particular firewall rule. If defined, 
    # logging is enabled, and logs will be exported to Cloud Logging.
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      metadata = try(each.value.log_config.metadata, null)
    }
  }
}
