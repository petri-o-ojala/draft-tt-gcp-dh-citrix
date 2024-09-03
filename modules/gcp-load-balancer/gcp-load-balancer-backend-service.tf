#
# GCP Load Balancer Backend Service
#

locals {
  # Groups available as backend
  backend_group = merge(
    {
      for key, value in local.gcp_compute_instance_group_manager : key => {
        group_resource = value.instance_group
      }
    },
    {
      for key, value in local.gcp_compute_instance_group : key => {
        group_resource = value.id
      }
    },
    {
      for key, value in local.gcp_network_endpoint_group : key => {
        group_resource = value.id
      }
    }
  )
}

locals {
  #
  # A variable with all the backend services for easy lookup
  #
  google_compute_backend_service = merge(
    google_compute_region_backend_service.lz,
    google_compute_backend_service.lz,
  )
}


resource "google_compute_region_backend_service" "lz" {
  #
  # GCPLB Backend Service (Regional)
  #
  for_each = {
    for backend_service in local.gcp_lb_backend_service : backend_service.resource_index => backend_service
    if backend_service.region != null
  }

  provider = google-beta

  name                            = each.value.name
  affinity_cookie_ttl_sec         = each.value.affinity_cookie_ttl_sec
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  description                     = each.value.description
  enable_cdn                      = each.value.enable_cdn
  health_checks = each.value.health_checks == null ? null : [
    for health_check in each.value.health_checks : lookup(google_compute_region_health_check.lz, health_check, null) == null ? health_check : google_compute_region_health_check.lz[health_check].self_link
  ]
  load_balancing_scheme = each.value.load_balancing_scheme
  locality_lb_policy    = each.value.locality_lb_policy
  port_name             = each.value.port_name
  protocol              = each.value.protocol
  security_policy       = each.value.security_policy
  session_affinity      = each.value.session_affinity
  timeout_sec           = each.value.timeout_sec
  network               = each.value.network
  region                = each.value.region
  project               = each.value.project

  dynamic "backend" {
    # (Optional) The set of backends that serve this RegionBackendService.
    for_each = coalesce(each.value.backend, [])

    content {
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
      description     = backend.value.description
      failover        = backend.value.failover
      #group                        = lookup(local.gcp_compute_instance_group_manager, backend.value.group, null) == null ? backend.value.group : local.gcp_compute_instance_group_manager[backend.value.group].instance_group
      group                        = lookup(local.backend_group, backend.value.group, null) == null ? backend.value.group : local.backend_group[backend.value.group].group_resource
      max_connections              = backend.value.max_connections
      max_connections_per_instance = backend.value.max_connections_per_instance
      max_connections_per_endpoint = backend.value.max_connections_per_endpoint
      max_rate                     = backend.value.max_rate
      max_rate_per_instance        = backend.value.max_rate_per_instance
      max_rate_per_endpoint        = backend.value.max_rate_per_endpoint
      max_utilization              = backend.value.max_utilization
    }
  }

  dynamic "circuit_breakers" {
    # (Optional) Settings controlling the volume of connections to a backend service. This field is applicable only 
    # when the load_balancing_scheme is set to INTERNAL_MANAGED and the protocol is set to HTTP, HTTPS, or HTTP2.
    for_each = try(each.value.circuit_breakers, null) == null ? [] : [1]

    content {
      max_requests_per_connection = each.value.circuit_breakers.max_requests_per_connection
      max_connections             = each.value.circuit_breakers.max_connections
      max_pending_requests        = each.value.circuit_breakers.max_pending_requests
      max_requests                = each.value.circuit_breakers.max_requests
      max_retries                 = each.value.circuit_breakers.max_retries

      dynamic "connect_timeout" {
        # (Optional, Beta) The timeout for new network connections to hosts.
        for_each = try(each.value.circuit_breakers.connect_timeout, null) == null ? [] : [1]

        content {
          seconds = each.value.circuit_breakers.connect_timeout.seconds
          nanos   = each.value.circuit_breakers.connect_timeout.nanos
        }
      }
    }
  }

  dynamic "consistent_hash" {
    # (Optional) Consistent Hash-based load balancing can be used to provide soft session affinity based on HTTP headers, 
    # cookies or other properties. This load balancing policy is applicable only for HTTP connections. The affinity to 
    # a particular destination host will be lost when one or more hosts are added/removed from the destination service. 
    # This field specifies parameters that control consistent hashing. 
    for_each = try(each.value.consistent_hash, null) == null ? [] : [1]

    content {
      http_header_name  = each.value.consistent_hash.http_http_header_nameookie
      minimum_ring_size = each.value.consistent_hash.minimum_ring_size

      dynamic "http_cookie" {
        for_each = try(each.value.consistent_hash.http_cookie, null) == null ? [] : [1]

        content {
          name = each.value.consistent_hash.http_cookie.name
          path = each.value.consistent_hash.http_cookie.path

          dynamic "ttl" {
            # (Optional) Lifetime of the cookie.
            for_each = try(each.value.consistent_hash.http_cookie.ttl, null) == null ? [] : [1]

            content {
              seconds = each.value.consistent_hash.http_cookie.ttl.seconds
              nanos   = each.value.consistent_hash.http_cookie.ttl.nanos
            }
          }
        }
      }
    }
  }

  dynamic "cdn_policy" {
    # (Optional) Cloud CDN configuration for this BackendService. 
    for_each = try(each.value.cdn_policy, null) == null ? [] : [1]

    content {
      signed_url_cache_max_age_sec = each.value.cdn_policy.signed_url_cache_max_age_sec
      default_ttl                  = each.value.cdn_policy.default_ttl
      max_ttl                      = each.value.cdn_policy.max_ttl
      client_ttl                   = each.value.cdn_policy.client_ttl
      negative_caching             = each.value.cdn_policy.negative_caching
      cache_mode                   = each.value.cdn_policy.cache_mode
      serve_while_stale            = each.value.cdn_policy.serve_while_stale

      dynamic "cache_key_policy" {
        # (Optional) The CacheKeyPolicy for this CdnPolicy.
        for_each = try(each.value.cdn_policy.cache_key_policy, null) == null ? [] : [1]

        content {
          include_host           = each.value.cdn_policy.cache_key_policy.include_host
          include_protocol       = each.value.cdn_policy.cache_key_policy.include_protocol
          include_query_string   = each.value.cdn_policy.cache_key_policy.include_query_string
          query_string_blacklist = each.value.cdn_policy.cache_key_policy.query_string_blacklist
          query_string_whitelist = each.value.cdn_policy.cache_key_policy.query_string_whitelist
          include_named_cookies  = each.value.cdn_policy.cache_key_policy.include_named_cookies
        }
      }

      dynamic "negative_caching_policy" {
        # (Optional) Sets a cache TTL for the specified HTTP status code. negativeCaching must be enabled to configure 
        # negativeCachingPolicy. Omitting the policy and leaving negativeCaching enabled will use Cloud CDN's 
        # default cache TTLs. 
        for_each = try(each.value.cdn_policy.negative_caching_policy, null) == null ? [] : [1]

        content {
          code = each.value.cdn_policy.negative_caching_policy.code
          ttl  = each.value.cdn_policy.negative_caching_policy.ttl
        }
      }
    }
  }

  dynamic "failover_policy" {
    # (Optional) Policy for failovers. 
    for_each = try(each.value.failover_policy, null) == null ? [] : [1]

    content {
      disable_connection_drain_on_failover = each.value.failover_policy.disable_connection_drain_on_failover
      drop_traffic_if_unhealthy            = each.value.failover_policy.drop_traffic_if_unhealthy
      failover_ratio                       = each.value.failover_policy.failover_ratio
    }
  }

  dynamic "iap" {
    # (Optional) Settings for enabling Cloud Identity Aware Proxy
    for_each = try(each.value.iap, null) == null ? [] : [1]

    content {
      oauth2_client_id            = each.value.iap.oauth2_client_id
      oauth2_client_secret        = each.value.iap.oauth2_client_secret
      oauth2_client_secret_sha256 = each.value.iap.oauth2_client_secret_sha256
    }
  }

  dynamic "outlier_detection" {
    # (Optional) Settings controlling eviction of unhealthy hosts from the load balancing pool. This field is applicable 
    # only when the load_balancing_scheme is set to INTERNAL_MANAGED and the protocol is set to HTTP, HTTPS, or HTTP2
    for_each = try(each.value.outlier_detection, null) == null ? [] : [1]

    content {
      consecutive_errors                    = each.value.outlier_detection.consecutive_errors
      consecutive_gateway_failure           = each.value.outlier_detection.consecutive_gateway_failure
      enforcing_consecutive_errors          = each.value.outlier_detection.enforcing_consecutive_errors
      enforcing_consecutive_gateway_failure = each.value.outlier_detection.enforcing_consecutive_gateway_failure
      enforcing_success_rate                = each.value.outlier_detection.enforcing_success_rate
      max_ejection_percent                  = each.value.outlier_detection.max_ejection_percent
      success_rate_minimum_hosts            = each.value.outlier_detection.success_rate_minimum_hosts
      success_rate_request_volume           = each.value.outlier_detection.success_rate_request_volume
      success_rate_stdev_factor             = each.value.outlier_detection.success_rate_stdev_factor

      dynamic "base_ejection_time" {
        # (Optional) The base time that a host is ejected for. The real time is equal to the base time multiplied by the 
        # number of times the host has been ejected. Defaults to 30000ms or 30s.
        for_each = try(each.value.outlier_detection.base_ejection_time, null) == null ? [] : [1]

        content {
          seconds = each.value.outlier_detection.base_ejection_time.seconds
          nanos   = each.value.outlier_detection.base_ejection_time.nanos
        }
      }

      dynamic "interval" {
        #  (Optional) Time interval between ejection sweep analysis. This can result in both new ejections as well as 
        # hosts being returned to service
        for_each = try(each.value.outlier_detection.interval, null) == null ? [] : [1]

        content {
          seconds = each.value.outlier_detection.interval.seconds
          nanos   = each.value.outlier_detection.interval.nanos
        }
      }
    }
  }

  dynamic "connection_tracking_policy" {
    # (Optional, Beta) Connection Tracking configuration for this BackendService. This is available only for Layer 4
    # Internal Load Balancing and Network Load Balancing.
    for_each = try(each.value.connection_tracking_policy, null) == null ? [] : [1]

    content {
      idle_timeout_sec                             = each.value.connection_tracking_policy.idle_timeout_sec
      tracking_mode                                = each.value.connection_tracking_policy.tracking_mode
      connection_persistence_on_unhealthy_backends = each.value.connection_tracking_policy.connection_persistence_on_unhealthy_backends
      enable_strong_affinity                       = each.value.connection_tracking_policy.enable_strong_affinity
    }
  }

  dynamic "log_config" {
    # (Optional) This field denotes the logging options for the load balancer traffic served by this backend service.
    # If logging is enabled, logs will be exported to Stackdriver.
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      enable      = each.value.log_config.enable
      sample_rate = each.value.log_config.sample_rate
    }
  }

  dynamic "subsetting" {
    # (Optional, Beta) Subsetting configuration for this BackendService. Currently this is applicable only for Internal
    # TCP/UDP load balancing and Internal HTTP(S) load balancing
    for_each = try(each.value.subsetting, null) == null ? [] : [1]

    content {
      policy = each.value.subsetting.policy
    }
  }
}

resource "google_compute_backend_service" "lz" {
  #
  # GCPLB Backend Service (Global)
  #
  for_each = {
    for backend_service in local.gcp_lb_backend_service : backend_service.resource_index => backend_service
    if backend_service.region == null
  }

  provider = google-beta

  name                            = each.value.name
  affinity_cookie_ttl_sec         = each.value.affinity_cookie_ttl_sec
  compression_mode                = each.value.compression_mode
  connection_draining_timeout_sec = each.value.connection_draining_timeout_sec
  custom_request_headers          = each.value.custom_request_headers
  custom_response_headers         = each.value.custom_response_headers
  description                     = each.value.description
  enable_cdn                      = each.value.enable_cdn
  health_checks = each.value.health_checks == null ? null : [
    for health_check in each.value.health_checks : lookup(google_compute_health_check.lz, health_check, null) == null ? health_check : google_compute_health_check.lz[health_check].self_link
  ]
  load_balancing_scheme = each.value.load_balancing_scheme
  port_name             = each.value.port_name
  protocol              = each.value.protocol
  security_policy       = each.value.security_policy
  edge_security_policy  = each.value.edge_security_policy
  session_affinity      = each.value.session_affinity
  timeout_sec           = each.value.timeout_sec
  project               = each.value.project

  dynamic "backend" {
    # (Optional) The set of backends that serve this RegionBackendService.
    for_each = coalesce(each.value.backend, [])

    content {
      balancing_mode  = backend.value.balancing_mode
      capacity_scaler = backend.value.capacity_scaler
      description     = backend.value.description
      # group                        = lookup(local.gcp_compute_instance_group_manager, backend.value.group, null) == null ? backend.value.group : local.gcp_compute_instance_group_manager[backend.value.group].instance_group
      group                        = lookup(local.backend_group, backend.value.group, null) == null ? backend.value.group : local.backend_group[backend.value.group].group_resource
      max_connections              = backend.value.max_connections
      max_connections_per_instance = backend.value.max_connections_per_instance
      max_connections_per_endpoint = backend.value.max_connections_per_endpoint
      max_rate                     = backend.value.max_rate
      max_rate_per_instance        = backend.value.max_rate_per_instance
      max_rate_per_endpoint        = backend.value.max_rate_per_endpoint
      max_utilization              = backend.value.max_utilization
    }
  }

  dynamic "circuit_breakers" {
    # (Optional) Settings controlling the volume of connections to a backend service. This field is applicable only 
    # when the load_balancing_scheme is set to INTERNAL_MANAGED and the protocol is set to HTTP, HTTPS, or HTTP2.
    for_each = try(each.value.circuit_breakers, null) == null ? [] : [1]

    content {
      max_requests_per_connection = each.value.circuit_breakers.max_requests_per_connection
      max_connections             = each.value.circuit_breakers.max_connections
      max_pending_requests        = each.value.circuit_breakers.max_pending_requests
      max_requests                = each.value.circuit_breakers.max_requests
      max_retries                 = each.value.circuit_breakers.max_retries

      dynamic "connect_timeout" {
        # (Optional, Beta) The timeout for new network connections to hosts.
        for_each = try(each.value.circuit_breakers.connect_timeout, null) == null ? [] : [1]

        content {
          seconds = each.value.circuit_breakers.connect_timeout.seconds
          nanos   = each.value.circuit_breakers.connect_timeout.nanos
        }
      }
    }
  }

  dynamic "consistent_hash" {
    # (Optional) Consistent Hash-based load balancing can be used to provide soft session affinity based on HTTP headers, 
    # cookies or other properties. This load balancing policy is applicable only for HTTP connections. The affinity to 
    # a particular destination host will be lost when one or more hosts are added/removed from the destination service. 
    # This field specifies parameters that control consistent hashing. 
    for_each = try(each.value.consistent_hash, null) == null ? [] : [1]

    content {
      http_header_name  = each.value.consistent_hash.http_http_header_nameookie
      minimum_ring_size = each.value.consistent_hash.minimum_ring_size

      dynamic "http_cookie" {
        for_each = try(each.value.consistent_hash.http_cookie, null) == null ? [] : [1]

        content {
          name = each.value.consistent_hash.http_cookie.name
          path = each.value.consistent_hash.http_cookie.path

          dynamic "ttl" {
            # (Optional) Lifetime of the cookie.
            for_each = try(each.value.consistent_hash.http_cookie.ttl, null) == null ? [] : [1]

            content {
              seconds = each.value.consistent_hash.http_cookie.ttl.seconds
              nanos   = each.value.consistent_hash.http_cookie.ttl.nanos
            }
          }
        }
      }
    }
  }

  dynamic "cdn_policy" {
    # (Optional) Cloud CDN configuration for this BackendService. 
    for_each = try(each.value.cdn_policy, null) == null ? [] : [1]

    content {
      signed_url_cache_max_age_sec = each.value.cdn_policy.signed_url_cache_max_age_sec
      default_ttl                  = each.value.cdn_policy.default_ttl
      max_ttl                      = each.value.cdn_policy.max_ttl
      client_ttl                   = each.value.cdn_policy.client_ttl
      negative_caching             = each.value.cdn_policy.negative_caching
      cache_mode                   = each.value.cdn_policy.cache_mode
      serve_while_stale            = each.value.cdn_policy.serve_while_stale

      dynamic "cache_key_policy" {
        # (Optional) The CacheKeyPolicy for this CdnPolicy.
        for_each = try(each.value.cdn_policy.cache_key_policy, null) == null ? [] : [1]

        content {
          include_host           = each.value.cdn_policy.cache_key_policy.include_host
          include_protocol       = each.value.cdn_policy.cache_key_policy.include_protocol
          include_query_string   = each.value.cdn_policy.cache_key_policy.include_query_string
          query_string_blacklist = each.value.cdn_policy.cache_key_policy.query_string_blacklist
          query_string_whitelist = each.value.cdn_policy.cache_key_policy.query_string_whitelist
          include_named_cookies  = each.value.cdn_policy.cache_key_policy.include_named_cookies
        }
      }

      dynamic "negative_caching_policy" {
        # (Optional) Sets a cache TTL for the specified HTTP status code. negativeCaching must be enabled to configure 
        # negativeCachingPolicy. Omitting the policy and leaving negativeCaching enabled will use Cloud CDN's 
        # default cache TTLs. 
        for_each = try(each.value.cdn_policy.negative_caching_policy, null) == null ? [] : [1]

        content {
          code = each.value.cdn_policy.negative_caching_policy.code
          ttl  = each.value.cdn_policy.negative_caching_policy.ttl
        }
      }
    }
  }

  dynamic "iap" {
    # (Optional) Settings for enabling Cloud Identity Aware Proxy
    for_each = try(each.value.iap, null) == null ? [] : [1]

    content {
      oauth2_client_id            = each.value.iap.oauth2_client_id
      oauth2_client_secret        = each.value.iap.oauth2_client_secret
      oauth2_client_secret_sha256 = each.value.iap.oauth2_client_secret_sha256
    }
  }

  dynamic "locality_lb_policies" {
    # (Optional) A list of locality load balancing policies to be used in order of preference. Either the policy or the 
    # customPolicy field should be set. Overrides any value set in the localityLbPolicy field. localityLbPolicies is only 
    # supported when the BackendService is referenced by a URL Map that is referenced by a target gRPC proxy that has the 
    # validateForProxyless field set to true.
    for_each = coalesce(each.value.locality_lb_policies, [])

    content {
      dynamic "policy" {
        for_each = try(locality_lb_policies.value.policy, null) == null ? [] : [1]

        content {
          name = locality_lb_policies.value.policy.name
        }
      }

      dynamic "custom_policy" {
        for_each = try(locality_lb_policies.value.custom_policy, null) == null ? [] : [1]

        content {
          name = locality_lb_policies.value.custom_policy.name
          data = locality_lb_policies.value.custom_policy.data
        }
      }
    }
  }

  dynamic "outlier_detection" {
    # (Optional) Settings controlling eviction of unhealthy hosts from the load balancing pool. This field is applicable 
    # only when the load_balancing_scheme is set to INTERNAL_MANAGED and the protocol is set to HTTP, HTTPS, or HTTP2
    for_each = try(each.value.outlier_detection, null) == null ? [] : [1]

    content {
      consecutive_errors                    = each.value.outlier_detection.consecutive_errors
      consecutive_gateway_failure           = each.value.outlier_detection.consecutive_gateway_failure
      enforcing_consecutive_errors          = each.value.outlier_detection.enforcing_consecutive_errors
      enforcing_consecutive_gateway_failure = each.value.outlier_detection.enforcing_consecutive_gateway_failure
      enforcing_success_rate                = each.value.outlier_detection.enforcing_success_rate
      max_ejection_percent                  = each.value.outlier_detection.max_ejection_percent
      success_rate_minimum_hosts            = each.value.outlier_detection.success_rate_minimum_hosts
      success_rate_request_volume           = each.value.outlier_detection.success_rate_request_volume
      success_rate_stdev_factor             = each.value.outlier_detection.success_rate_stdev_factor

      dynamic "base_ejection_time" {
        # (Optional) The base time that a host is ejected for. The real time is equal to the base time multiplied by the 
        # number of times the host has been ejected. Defaults to 30000ms or 30s.
        for_each = try(each.value.outlier_detection.base_ejection_time, null) == null ? [] : [1]

        content {
          seconds = each.value.outlier_detection.base_ejection_time.seconds
          nanos   = each.value.outlier_detection.base_ejection_time.nanos
        }
      }

      dynamic "interval" {
        #  (Optional) Time interval between ejection sweep analysis. This can result in both new ejections as well as 
        # hosts being returned to service
        for_each = try(each.value.outlier_detection.interval, null) == null ? [] : [1]

        content {
          seconds = each.value.outlier_detection.interval.seconds
          nanos   = each.value.outlier_detection.interval.nanos
        }
      }
    }
  }

  dynamic "security_settings" {
    # (Optional) The security settings that apply to this backend service. This field is applicable to either a regional backend service with the service_protocol set to HTTP, HTTPS, or HTTP2, and load_balancing_scheme set to INTERNAL_MANAGED; or a global backend service with the load_balancing_scheme set to INTERNAL_SELF_MANAGED.
    for_each = try(each.value.security_settings, null) == null ? [] : [1]

    content {
      client_tls_policy = each.value.security_settings.client_tls_policy
      subject_alt_names = each.value.security_settings.subject_alt_names
    }
  }

  dynamic "log_config" {
    # (Optional) This field denotes the logging options for the load balancer traffic served by this backend service.
    # If logging is enabled, logs will be exported to Stackdriver.
    for_each = try(each.value.log_config, null) == null ? [] : [1]

    content {
      enable      = each.value.log_config.enable
      sample_rate = each.value.log_config.sample_rate
    }
  }
}

