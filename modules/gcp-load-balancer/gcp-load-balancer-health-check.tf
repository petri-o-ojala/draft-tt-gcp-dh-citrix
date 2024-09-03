#
# GCP Load Balancer Health checks
#

resource "google_compute_region_health_check" "lz" {
  #
  # GCLB Health Check (Regional)
  #
  for_each = {
    for check in local.gcp_lb_health_check : check.resource_index => check
    if check.region != null
  }

  provider = google-beta

  name                = each.value.name
  check_interval_sec  = each.value.check_interval_sec
  description         = each.value.description
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  timeout_sec         = each.value.timeout_sec
  region              = each.value.region
  project             = each.value.project

  dynamic "http_health_check" {
    for_each = try(each.value.http_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.http_health_check.host
      request_path       = each.value.http_health_check.request_path
      response           = each.value.http_health_check.response
      port               = each.value.http_health_check.port
      port_name          = each.value.http_health_check.port_name
      proxy_header       = each.value.http_health_check.proxy_header
      port_specification = each.value.http_health_check.port_specification
    }
  }

  dynamic "https_health_check" {
    for_each = try(each.value.https_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.https_health_check.host
      request_path       = each.value.https_health_check.request_path
      response           = each.value.https_health_check.response
      port               = each.value.https_health_check.port
      port_name          = each.value.https_health_check.port_name
      proxy_header       = each.value.https_health_check.proxy_header
      port_specification = each.value.https_health_check.port_specification
    }
  }

  dynamic "tcp_health_check" {
    for_each = try(each.value.tcp_health_check, null) == null ? [] : [1]

    content {
      request            = each.value.tcp_health_check.request
      response           = each.value.tcp_health_check.response
      port               = each.value.tcp_health_check.port
      port_name          = each.value.tcp_health_check.port_name
      proxy_header       = each.value.tcp_health_check.proxy_header
      port_specification = each.value.tcp_health_check.port_specification
    }
  }

  dynamic "ssl_health_check" {
    for_each = try(each.value.ssl_health_check, null) == null ? [] : [1]

    content {
      request            = each.value.ssl_health_check.request
      response           = each.value.ssl_health_check.response
      port               = each.value.ssl_health_check.port
      port_name          = each.value.ssl_health_check.port_name
      proxy_header       = each.value.ssl_health_check.proxy_header
      port_specification = each.value.ssl_health_check.port_specification
    }
  }

  dynamic "log_config" {
    # (Optional) Configure logging on this health check. 
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      enable = each.value.log_config.enable
    }
  }
}

resource "google_compute_health_check" "lz" {
  #
  # GCLB Health Check (Global)
  #
  for_each = {
    for check in local.gcp_lb_health_check : check.resource_index => check
    if check.region == null
  }

  provider = google-beta

  name                = each.value.name
  check_interval_sec  = each.value.check_interval_sec
  description         = each.value.description
  healthy_threshold   = each.value.healthy_threshold
  unhealthy_threshold = each.value.unhealthy_threshold
  timeout_sec         = each.value.timeout_sec
  project             = each.value.project

  dynamic "http_health_check" {
    for_each = try(each.value.http_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.http_health_check.host
      request_path       = each.value.http_health_check.request_path
      response           = each.value.http_health_check.response
      port               = each.value.http_health_check.port
      port_name          = each.value.http_health_check.port_name
      proxy_header       = each.value.http_health_check.proxy_header
      port_specification = each.value.http_health_check.port_specification
    }
  }

  dynamic "https_health_check" {
    for_each = try(each.value.https_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.https_health_check.host
      request_path       = each.value.https_health_check.request_path
      response           = each.value.https_health_check.response
      port               = each.value.https_health_check.port
      port_name          = each.value.https_health_check.port_name
      proxy_header       = each.value.https_health_check.proxy_header
      port_specification = each.value.https_health_check.port_specification
    }
  }

  dynamic "tcp_health_check" {
    for_each = try(each.value.tcp_health_check, null) == null ? [] : [1]

    content {
      request            = each.value.tcp_health_check.request
      response           = each.value.tcp_health_check.response
      port               = each.value.tcp_health_check.port
      port_name          = each.value.tcp_health_check.port_name
      proxy_header       = each.value.tcp_health_check.proxy_header
      port_specification = each.value.tcp_health_check.port_specification
    }
  }

  dynamic "ssl_health_check" {
    for_each = try(each.value.ssl_health_check, null) == null ? [] : [1]

    content {
      request            = each.value.ssl_health_check.request
      response           = each.value.ssl_health_check.response
      port               = each.value.ssl_health_check.port
      port_name          = each.value.ssl_health_check.port_name
      proxy_header       = each.value.ssl_health_check.proxy_header
      port_specification = each.value.ssl_health_check.port_specification
    }
  }

  dynamic "log_config" {
    # (Optional) Configure logging on this health check. 
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      enable = each.value.log_config.enable
    }
  }
}
