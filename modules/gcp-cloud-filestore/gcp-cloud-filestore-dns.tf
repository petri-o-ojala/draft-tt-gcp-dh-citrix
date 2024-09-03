#
# GCP Load Balancer DNS records
#

resource "google_dns_record_set" "memorystore_instance" {
  #
  # DNS Records
  #
  for_each = {
    for record in local.gcp_filestore_instance_dns : record.resource_index => record
  }

  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  managed_zone = each.value.managed_zone
  project      = each.value.project


  rrdatas = each.value.rr_data_address == true ? each.value.filestore_instance_ip_addresses : each.value.rr_data
}
