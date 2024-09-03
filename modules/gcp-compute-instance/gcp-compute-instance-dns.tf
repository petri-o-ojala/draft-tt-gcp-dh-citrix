#
# GCP Compute Engine DNS records
#

resource "google_dns_record_set" "lz" {
  #
  # DNS Records
  #
  for_each = {
    for compute_address in local.gcp_compute_address : compute_address.resource_index => compute_address
    if compute_address.dns != null
  }

  name         = each.value.dns.instance_hostname == true ? endswith(google_compute_instance.lz[each.value.dns.instance].hostname, ".") ? google_compute_instance.lz[each.value.dns.instance].hostname : "${google_compute_instance.lz[each.value.dns.instance].hostname}." : each.value.dns.name
  type         = each.value.dns.type
  ttl          = each.value.dns.ttl
  managed_zone = each.value.dns.managed_zone
  project      = each.value.dns.project

  rrdatas = each.value.dns.rr_data_address == true ? [local.google_compute_address[each.key].address] : each.value.dns.rr_data
}

locals {
  gcp_compute_instance_dns_record = flatten([
    for instance in local.gcp_compute_instance : [
      for dns_record in instance.dns : merge(
        dns_record,
        {
          instance_resource_index = instance.resource_index
          resource_index          = join("_", [instance.resource_index, dns_record.managed_zone, dns_record.name])
        }
      )
    ]
    if instance.dns != null
  ])
}

resource "google_dns_record_set" "gce" {
  #
  # DNS Records for GCE Instances
  #
  for_each = {
    for dns_record in local.gcp_compute_instance_dns_record : dns_record.resource_index => dns_record
  }

  name         = each.value.name
  type         = each.value.type
  ttl          = each.value.ttl
  managed_zone = each.value.managed_zone
  project      = each.value.project


  rrdatas = each.value.rr_data_address == true ? [local.google_compute_instance[each.value.instance_resource_index].network_interface[each.value.rr_data_address_index].network_ip] : each.value.rr_data
}
