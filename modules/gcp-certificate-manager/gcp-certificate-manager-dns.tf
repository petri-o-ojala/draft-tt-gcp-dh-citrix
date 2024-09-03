#
# GCP Certificate Manager
#

locals {
  google_certificate_manager_dns_authorization = google_certificate_manager_dns_authorization.lz
}

resource "google_certificate_manager_dns_authorization" "lz" {
  #
  # GCP Certificate Manager DNS Authorisations
  #
  for_each = {
    for authorization in local.gcp_certificate_manager_dns_authorization : authorization.resource_index => authorization
  }

  domain = each.value.domain
  name   = each.value.name

  description = each.value.description
  project     = each.value.project
  location    = each.value.location
  type        = each.value.type
  labels      = each.value.labels
}

#
# Add Certificate DNS records
#

locals {
  google_certificate_dns_records = flatten([
    for authorization_id, authorization in google_certificate_manager_dns_authorization.lz : [
      for dns_record in authorization.dns_resource_record : {
        resource_index = authorization_id
        name           = dns_record.name
        project        = try(local.certificate_manager.certificate[authorization_id].managed_zone.project, null)
        project        = try(local.certificate_manager.certificate[authorization_id].managed_zone.name, null)
        type           = dns_record.type
        ttl            = coalesce(try(local.certificate_manager.certificate[authorization_id].managed_zone.ttl, null), 1800)
        rr_data = [
          dns_record.data
        ]
      }
      if try(local.certificate_manager.certificate[authorization_id].managed_zone, null) != null
    ]
  ])
  /*
  google_certificate_manager_dns_authorization_records = flatten(
    [
      for authorization in local.gcp_certificate_manager_dns_authorization : [
        for dns_record in google_certificate_manager_dns_authorization.lz[authorization.resource_index].dns_resource_record : {
          resource_index = join("_", [authorization.domain])
          name           = dns_record.name
          project        = authorization.managed_zone.project
          managed_zone   = authorization.managed_zone.name
          type           = dns_record.type
          ttl            = coalesce(authorization.managed_zone.ttl, 1800)
          rr_data = [
            dns_record.data
          ]
        }
        if authorization.managed_zone != null
      ]
    ]
  )
*/
}

resource "google_dns_record_set" "lz" {
  for_each = {
    for authorization in local.gcp_certificate_manager_dns_authorization : authorization.resource_index => authorization
    if authorization.managed_zone != null
  }

  name         = google_certificate_manager_dns_authorization.lz[each.key].dns_resource_record[0].name
  type         = google_certificate_manager_dns_authorization.lz[each.key].dns_resource_record[0].type
  ttl          = each.value.managed_zone.ttl
  managed_zone = each.value.managed_zone.name
  project      = each.value.managed_zone.project

  rrdatas = [
    google_certificate_manager_dns_authorization.lz[each.key].dns_resource_record[0].data
  ]

  depends_on = [
    google_certificate_manager_dns_authorization.lz
  ]
}
