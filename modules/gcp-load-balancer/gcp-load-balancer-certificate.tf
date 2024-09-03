#
# GCP Load Balancer SSL Certificates
#

resource "google_compute_region_ssl_certificate" "lz" {
  #
  # GCLB SSL Certificate (Regional)
  #
  for_each = {
    for certificate in local.gcp_lb_certificate : certificate.resource_index => certificate
    if certificate.region != null && certificate.google_managed != true
  }

  certificate = each.value.certificate
  private_key = each.value.private_key
  description = each.value.description
  name        = each.value.name
  region      = each.value.region
  project     = each.value.project
  name_prefix = each.value.name_prefix
}

resource "google_compute_ssl_certificate" "lz" {
  #
  # GCLB SSL Certificate (Global)
  #
  for_each = {
    for certificate in local.gcp_lb_certificate : certificate.resource_index => certificate
    if certificate.region == null && certificate.google_managed != true
  }

  certificate = each.value.certificate
  private_key = each.value.private_key
  description = each.value.description
  name        = each.value.name
  project     = each.value.project
  name_prefix = each.value.name_prefix
}

resource "google_compute_managed_ssl_certificate" "lz" {
  #
  # GCLB Managed SSL Certificate
  #
  for_each = {
    for certificate in local.gcp_lb_certificate : certificate.resource_index => certificate
    if certificate.google_managed == true
  }

  description = each.value.description
  name        = each.value.name
  type        = each.value.type
  project     = each.value.project

  dynamic "managed" {
    for_each = try(each.value.managed, null) == null ? [] : [1]

    content {
      # (Optional) Properties relevant to a managed certificate. These will be used if the certificate is managed 
      # (as indicated by a value of MANAGED in type). 
      domains = each.value.managed.domains
    }
  }
}

locals {
  #
  # A variable with all the certificates for easy lookup
  #
  google_ssl_certificate = merge(
    google_compute_region_ssl_certificate.lz,
    google_compute_ssl_certificate.lz,
    google_compute_managed_ssl_certificate.lz
  )
}
