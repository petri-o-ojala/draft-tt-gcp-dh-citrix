#
# Google Managed Certificates
#

locals {
  google_certificate_manager_certificate = google_certificate_manager_certificate.lz
}

resource "google_certificate_manager_certificate" "lz" {
  #
  # GCP Certificate Manager Certificates
  #
  for_each = {
    for certificate in local.gcp_certificate_manager_certificate : certificate.resource_index => certificate
  }

  name = each.value.name

  description = each.value.description
  labels      = each.value.labels
  scope       = each.value.scope
  location    = each.value.location
  project     = each.value.project

  dynamic "self_managed" {
    # (Optional) Certificate data for a SelfManaged Certificate. SelfManaged Certificates are uploaded by the user. Updating such certificates before they expire remains the user's responsibility. 
    for_each = try(each.value.self_managed, null) == null ? [] : [1]

    content {
      pem_certificate = each.value.self_managed.pem_certificate
      pem_private_key = each.value.self_managed.pem_private_key
    }
  }

  dynamic "managed" {
    # (Optional) Configuration and state of a Managed Certificate. Certificate Manager provisions and renews Managed Certificates automatically, for as long as it's authorized to do so.
    for_each = try(each.value.managed, null) == null ? [] : [1]

    content {
      domains = each.value.managed.domains == null ? null : [
        for domain in each.value.managed.domains : lookup(local.google_certificate_manager_dns_authorization, domain, null) == null ? domain : local.google_certificate_manager_dns_authorization[domain].domain
      ]
      dns_authorizations = each.value.managed.dns_authorizations == null ? null : [
        for authorization in each.value.managed.dns_authorizations : lookup(local.google_certificate_manager_dns_authorization, authorization, null) == null ? authorization : local.google_certificate_manager_dns_authorization[authorization].id
      ]
      issuance_config = each.value.managed.issuance_config
    }
  }
}

resource "google_certificate_manager_certificate_map" "lz" {
  #
  # GCP Certificate Manager Certificate Maps
  #
  for_each = {
    for map in local.gcp_certificate_manager_certificate_map : map.resource_index => map
  }

  name = each.value.name

  description = each.value.description
  labels      = each.value.labels
  project     = each.value.project
}

resource "google_certificate_manager_certificate_map_entry" "lz" {
  #
  # GCP Certificate Manager Certificate Map entries
  #
  for_each = {
    for entry in local.gcp_certificate_manager_certificate_map_entry : entry.resource_index => entry
  }

  name        = each.value.name
  description = each.value.description
  project     = each.value.project
  labels      = each.value.labels

  matcher  = each.value.matcher
  hostname = each.value.hostname
  map      = each.value.map_resource.name
  certificates = [
    for certificate in coalesce(each.value.certificates, []) : lookup(local.google_certificate_manager_certificate, certificate, null) == null ? certificate : local.google_certificate_manager_certificate[certificate].id
  ]
}
