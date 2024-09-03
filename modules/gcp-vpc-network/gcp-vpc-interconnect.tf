#
# GCP InterConnect
#

locals {
  google_compute_interconnect_attachment = google_compute_interconnect_attachment.lz
}

#

resource "google_compute_interconnect_attachment" "lz" {
  #
  # Interconnect Attachments
  #
  for_each = {
    for attachment in local.gcp_interconnect_attachment : attachment.resource_index => attachment
  }

  name   = each.value.name
  router = lookup(local.google_compute_router, each.value.router, null) == null ? each.value.router : local.google_compute_router[each.value.router].self_link

  admin_enabled            = each.value.admin_enabled
  interconnect             = each.value.interconnect
  description              = each.value.description
  mtu                      = each.value.mtu
  bandwidth                = each.value.bandwidth
  edge_availability_domain = each.value.edge_availability_domain
  type                     = each.value.type
  candidate_subnets        = each.value.candidate_subnets
  vlan_tag8021q            = each.value.vlan_tag8021q
  ipsec_internal_addresses = each.value.ipsec_internal_addresses
  encryption               = each.value.encryption
  region                   = each.value.region
  project                  = each.value.project
}
