#
# GCP PSC Producer
#

resource "google_compute_service_attachment" "lz" {
  for_each = {
    for attachment in local.gcp_psc_attachment : attachment.resource_index => attachment
  }

  name                  = each.value.name
  connection_preference = each.value.connection_preference
  target_service        = lookup(local.google_compute_forwarding_rule, each.value.target_service, null) == null ? each.value.target_service : local.google_compute_forwarding_rule[each.value.target_service].id
  nat_subnets           = each.value.nat_subnets
  enable_proxy_protocol = each.value.enable_proxy_protocol
  description           = each.value.description
  domain_names          = each.value.domain_names
  consumer_reject_lists = each.value.consumer_reject_lists
  reconcile_connections = each.value.reconcile_connections
  region                = each.value.region
  project               = each.value.project

  dynamic "consumer_accept_lists" {
    # (Optional) An array of projects that are allowed to connect to this service attachment.
    for_each = coalesce(each.value.consumer_accept_lists, [])

    content {
      project_id_or_num = consumer_accept_lists.value.project_id_or_num
      connection_limit  = consumer_accept_lists.value.connection_limit
    }
  }
}
