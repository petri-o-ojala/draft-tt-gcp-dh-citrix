#
# GCP Load Balancer Proxy configurations
#

resource "google_compute_region_target_tcp_proxy" "lz" {
  #
  # GCLB TCP Proxy (Regional)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region != null && proxy.proxy_type == "TCP"
  }

  name            = each.value.name
  backend_service = lookup(local.google_compute_backend_service, each.value.backend_service, null) == null ? each.value.backend_service : local.google_compute_backend_service[each.value.backend_service].self_link
  description     = each.value.description
  proxy_header    = each.value.proxy_header
  proxy_bind      = each.value.proxy_bind
  region          = each.value.region
  project         = each.value.project
}

resource "google_compute_target_tcp_proxy" "lz" {
  #
  # GCLB TCP Proxy (Global)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region == null && proxy.proxy_type == "TCP"
  }

  name            = each.value.name
  backend_service = lookup(local.google_compute_backend_service, each.value.backend_service, null) == null ? each.value.backend_service : local.google_compute_backend_service[each.value.backend_service].self_link
  description     = each.value.description
  proxy_header    = each.value.proxy_header
  proxy_bind      = each.value.proxy_bind
  project         = each.value.project
}

resource "google_compute_region_target_http_proxy" "lz" {
  #
  # GCLB HTTP Proxy (Regional)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region != null && proxy.proxy_type == "HTTP"
  }

  name        = each.value.name
  url_map     = each.value.url_map == null ? null : lookup(google_compute_region_url_map.lz, each.value.url_map, null) == null ? each.value.url_map : google_compute_region_url_map.lz[each.value.url_map].self_link
  description = each.value.description
  region      = each.value.region
  project     = each.value.project
}

resource "google_compute_target_http_proxy" "lz" {
  #
  # GCLB HTTP Proxy (Global)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region == null && proxy.proxy_type == "HTTP"
  }

  name                        = each.value.name
  url_map                     = each.value.url_map == null ? null : lookup(google_compute_url_map.lz, each.value.url_map, null) == null ? each.value.url_map : google_compute_url_map.lz[each.value.url_map].self_link
  description                 = each.value.description
  proxy_bind                  = each.value.proxy_bind
  http_keep_alive_timeout_sec = each.value.http_keep_alive_timeout_sec
  project                     = each.value.project
}

resource "google_compute_region_target_https_proxy" "lz" {
  #
  # GCLB HTTPS Proxy (Regional)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region != null && proxy.proxy_type == "HTTPS"
  }

  name        = each.value.name
  region      = each.value.region
  url_map     = each.value.url_map == null ? null : lookup(google_compute_region_url_map.lz, each.value.url_map, null) == null ? each.value.url_map : google_compute_region_url_map.lz[each.value.url_map].self_link
  description = each.value.description
  ssl_certificates = each.value.ssl_certificates == null ? null : [
    for certificate in each.value.ssl_certificates : lookup(local.google_ssl_certificate, certificate, null) == null ? certificate : local.google_ssl_certificate[certificate].id
  ]
  ssl_policy = each.value.ssl_policy == null ? null : lookup(local.google_compute_ssl_policy, each.value.ssl_policy, null) == null ? each.value.ssl_policy : local.google_compute_ssl_policy[each.value.ssl_policy].self_link
  project    = each.value.project
}

resource "google_compute_target_https_proxy" "lz" {
  #
  # GCLB HTTPS Proxy (Global)
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.region == null && proxy.proxy_type == "HTTPS"
  }

  name          = each.value.name
  url_map       = each.value.url_map == null ? null : lookup(google_compute_url_map.lz, each.value.url_map, null) == null ? each.value.url_map : google_compute_url_map.lz[each.value.url_map].self_link
  description   = each.value.description
  quic_override = each.value.quic_override
  certificate_manager_certificates = each.value.certificate_manager_certificates == null ? null : [
    for certificate in each.value.certificate_manager_certificates : lookup(local.gcp_certificate_manager_certificate, certificate, null) == null ? certificate : local.gcp_certificate_manager_certificate[certificate].id
  ]
  ssl_certificates = each.value.ssl_certificates == null ? null : [
    for certificate in each.value.ssl_certificates : lookup(local.google_ssl_certificate, certificate, null) == null ? certificate : local.google_ssl_certificate[certificate].id
  ]
  certificate_map             = each.value.certificate_map == null ? null : lookup(local.gcp_certificate_manager_certificate_map, each.value.certificate_map, null) == null ? each.value.certificate_map : "//certificatemanager.googleapis.com/${local.gcp_certificate_manager_certificate_map[each.value.certificate_map].id}"
  ssl_policy                  = each.value.ssl_policy == null ? null : lookup(local.google_compute_ssl_policy, each.value.ssl_policy, null) == null ? each.value.ssl_policy : local.google_compute_ssl_policy[each.value.ssl_policy].self_link
  proxy_bind                  = each.value.proxy_bind
  http_keep_alive_timeout_sec = each.value.http_keep_alive_timeout_sec
  server_tls_policy           = each.value.server_tls_policy
  project                     = each.value.project
}

resource "google_compute_target_ssl_proxy" "lz" {
  #
  # GCLB SSL Proxy 
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.proxy_type == "SSL"
  }

  name             = each.value.name
  backend_service  = each.value.backend_service
  description      = each.value.description
  proxy_header     = each.value.proxy_header
  ssl_certificates = each.value.ssl_certificates
  certificate_map  = each.value.certificate_map
  ssl_policy       = each.value.ssl_policy
  project          = each.value.project
}

resource "google_compute_target_grpc_proxy" "lz" {
  #
  # GCLB GRPC Proxy 
  #
  for_each = {
    for proxy in local.gcp_lb_proxy : proxy.resource_index => proxy
    if proxy.proxy_type == "GRPC"
  }

  name                   = each.value.name
  description            = each.value.description
  url_map                = each.value.url_map
  validate_for_proxyless = each.value.validate_for_proxyless
  project                = each.value.project
}

locals {
  #
  # A variable with all the Proxies for easy lookup
  #
  google_compute_proxy = merge(
    google_compute_region_target_tcp_proxy.lz,
    google_compute_target_tcp_proxy.lz,
    google_compute_region_target_http_proxy.lz,
    google_compute_target_http_proxy.lz,
    google_compute_region_target_https_proxy.lz,
    google_compute_target_https_proxy.lz,
    google_compute_target_ssl_proxy.lz,
    google_compute_target_grpc_proxy.lz,
  )
}
