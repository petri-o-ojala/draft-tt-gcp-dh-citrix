#
# GCP Load Balancer SSL/Security Policies
#

resource "google_compute_region_ssl_policy" "lz" {
  #
  # GCLB SSL Policy (Regional)
  #
  for_each = {
    for policy in local.gcp_lb_ssl_policy : policy.resource_index => policy
    if policy.region != null
  }

  name            = each.value.name
  region          = each.value.region
  description     = each.value.description
  profile         = each.value.profile
  min_tls_version = each.value.min_tls_version
  custom_features = each.value.custom_features
  project         = each.value.project
}

resource "google_compute_ssl_policy" "lz" {
  #
  # GCLB SSL Policy (Global)
  #
  for_each = {
    for policy in local.gcp_lb_ssl_policy : policy.resource_index => policy
    if policy.region == null
  }

  name            = each.value.name
  description     = each.value.description
  profile         = each.value.profile
  min_tls_version = each.value.min_tls_version
  custom_features = each.value.custom_features
  project         = each.value.project
}

locals {
  #
  # A variable with all the SSL Policies for easy lookup
  #
  google_compute_ssl_policy = merge(
    google_compute_region_ssl_policy.lz,
    google_compute_ssl_policy.lz,
  )
}
