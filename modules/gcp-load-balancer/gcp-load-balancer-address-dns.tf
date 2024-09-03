#
# GCP Load Balancer DNS records
#

resource "google_dns_record_set" "gclb" {
  #
  # DNS Records
  #
  for_each = {
    for address in local.gcp_lb_compute_address_dns : address.resource_index => address
  }

  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  managed_zone = each.value.managed_zone
  project      = each.value.project


  rrdatas = each.value.rr_data_address == true ? [local.google_compute_address[each.value.address_id].address] : each.value.rr_data
}
