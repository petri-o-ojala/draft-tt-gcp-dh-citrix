#
# GCP Load Balancer DNS records
#

resource "google_dns_record_set" "gclz" {
  #
  # DNS Records
  #
  for_each = {
    for address in local.gcp_psc_address : address.resource_index => address
    if address.dns != null
  }

  name         = each.value.dns.name
  type         = each.value.dns.type
  ttl          = each.value.dns.ttl
  managed_zone = each.value.dns.managed_zone
  project      = each.value.dns.project


  rrdatas = each.value.dns.rr_data_address == true ? [local.google_compute_address[each.key].address] : each.value.dns.rr_data
}
