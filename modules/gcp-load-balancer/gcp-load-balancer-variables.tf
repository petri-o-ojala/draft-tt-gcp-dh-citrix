#
# GCP Load Balancers
#

/*
resource "google_compute_security_policy" "sas" {
  */

variable "gclb" {
  description = "GCLB configurations"
  type = object({
    certificate = optional(map(object({
      google_managed = optional(bool)
      region         = optional(string)
      certificate    = optional(string)
      private_key    = optional(string)
      description    = optional(string)
      name           = optional(string)
      project        = optional(string)
      name_prefix    = optional(string)
      type           = optional(string)
      managed = optional(object({
        domains = optional(list(string))
      }))
    })))
    ssl_policy = optional(map(object({
      name            = optional(string)
      region          = optional(string)
      description     = optional(string)
      profile         = optional(string)
      min_tls_version = optional(string)
      custom_features = optional(list(string))
      project         = optional(string)
    })))
    proxy = optional(map(object({
      proxy_type                       = string
      region                           = optional(string)
      name                             = optional(string)
      backend_service                  = optional(string)
      description                      = optional(string)
      proxy_header                     = optional(string)
      proxy_bind                       = optional(string)
      project                          = optional(string)
      url_map                          = optional(string)
      http_keep_alive_timeout_sec      = optional(number)
      quic_override                    = optional(bool)
      certificate_manager_certificates = optional(list(string))
      ssl_certificates                 = optional(list(string))
      certificate_map                  = optional(string)
      ssl_policy                       = optional(string)
      server_tls_policy                = optional(string)
      validate_for_proxyless           = optional(bool)
    })))
    backend = optional(map(object({
      name                            = string
      affinity_cookie_ttl_sec         = optional(number)
      connection_draining_timeout_sec = optional(number)
      custom_request_headers          = optional(list(string))
      custom_response_headers         = optional(list(string))
      description                     = optional(string)
      enable_cdn                      = optional(bool)
      health_checks                   = optional(list(string))
      load_balancing_scheme           = optional(string)
      locality_lb_policy              = optional(string)
      port_name                       = optional(string)
      protocol                        = optional(string)
      security_policy                 = optional(string)
      edge_security_policy            = optional(string)
      session_affinity                = optional(string)
      compression_mode                = optional(string)
      timeout_sec                     = optional(number)
      network                         = optional(string)
      region                          = optional(string)
      project                         = optional(string)
      backend = optional(list(object({
        balancing_mode               = optional(string)
        capacity_scaler              = optional(string)
        description                  = optional(string)
        failover                     = optional(string)
        group                        = string
        max_connections              = optional(number)
        max_connections_per_instance = optional(number)
        max_connections_per_endpoint = optional(number)
        max_rate                     = optional(number)
        max_rate_per_instance        = optional(number)
        max_rate_per_endpoint        = optional(number)
        max_utilization              = optional(number)
      })))
      circuit_breakers = optional(object({
        max_requests_per_connection = optional(number)
        max_connections             = optional(number)
        max_pending_requests        = optional(number)
        max_requests                = optional(number)
        max_retries                 = optional(number)
        connect_timeout = optional(object({
          seconds = optional(number)
          nanos   = optional(number)
        }))
      }))
      consistent_hash = optional(object({
        http_header_name  = optional(string)
        minimum_ring_size = optional(number)
        http_cookie = optional(object({
          name = optional(string)
          path = optional(string)
          ttl = optional(object({
            seconds = optional(number)
            nanos   = optional(number)
          }))
        }))
      }))
      cdn_policy = optional(object({
        signed_url_cache_max_age_sec = optional(number)
        default_ttl                  = optional(number)
        max_ttl                      = optional(number)
        client_ttl                   = optional(number)
        negative_caching             = optional(bool)
        cache_mode                   = optional(string)
        serve_while_stale            = optional(bool)
        cache_key_policy = optional(object({
          include_host           = optional(string)
          include_protocol       = optional(string)
          include_query_string   = optional(string)
          query_string_blacklist = optional(string)
          query_string_whitelist = optional(string)
          include_named_cookies  = optional(string)
        }))
        negative_caching_policy = optional(object({
          code = optional(string)
          ttl  = optional(number)
        }))
      }))
      failover_policy = optional(object({
        disable_connection_drain_on_failover = optional(bool)
        drop_traffic_if_unhealthy            = optional(bool)
        failover_ratio                       = optional(number)
      }))
      iap = optional(object({
        oauth2_client_id            = optional(string)
        oauth2_client_secret        = optional(string)
        oauth2_client_secret_sha256 = optional(string)
      }))
      locality_lb_policies = optional(list(object({
        policy = optional(object({
          name = optional(string)
        }))
        custom_policy = optional(object({
          name = optional(string)
          data = optional(string)
        }))
      })))
      outlier_detection = optional(object({
        consecutive_errors                    = optional(number)
        consecutive_gateway_failure           = optional(number)
        enforcing_consecutive_errors          = optional(number)
        enforcing_consecutive_gateway_failure = optional(number)
        enforcing_success_rate                = optional(number)
        max_ejection_percent                  = optional(number)
        success_rate_minimum_hosts            = optional(number)
        success_rate_request_volume           = optional(number)
        success_rate_stdev_factor             = optional(number)
        base_ejection_time = optional(object({
          seconds = optional(number)
          nanos   = optional(number)
        }))
        interval = optional(object({
          seconds = optional(number)
          nanos   = optional(number)
        }))
      }))
      security_settings = optional(object({
        client_tls_policy = optional(string)
        subject_alt_names = optional(list(string))
      }))
      connection_tracking_policy = optional(object({
        idle_timeout_sec                             = optional(number)
        tracking_mode                                = optional(string)
        connection_persistence_on_unhealthy_backends = optional(string)
        enable_strong_affinity                       = optional(bool)
      }))
      log_config = optional(object({
        enable      = optional(bool)
        sample_rate = optional(number)
      }))
      subsetting = optional(object({
        policy = optional(string)
      }))
    })))
    address = optional(map(object({
      name               = string
      description        = optional(string)
      region             = optional(string)
      project            = optional(string)
      address            = optional(string)
      address_type       = optional(string)
      purpose            = optional(string)
      network_tier       = optional(string)
      subnetwork         = optional(string)
      labels             = optional(map(string))
      network            = optional(string)
      prefix_length      = optional(number)
      ip_version         = optional(string)
      ipv6_endpoint_type = optional(string)
      dns = optional(list(object({
        name            = string
        type            = optional(string, "A")
        ttl             = optional(number, 300)
        managed_zone    = string
        project         = optional(string)
        rr_data_address = optional(bool)
        rr_data         = optional(list(string))
      })))
    })))
    forwarding_rule = optional(map(object({
      name                    = string
      project                 = optional(string)
      is_mirroring_collector  = optional(bool)
      description             = optional(string)
      ip_address              = optional(string)
      ip_protocol             = optional(string)
      backend_service         = optional(string)
      load_balancing_scheme   = optional(string)
      network                 = optional(string)
      port_range              = optional(string)
      ports                   = optional(list(string))
      subnetwork              = optional(string)
      target                  = optional(string)
      allow_global_access     = optional(bool)
      labels                  = optional(map(string))
      all_ports               = optional(bool)
      network_tier            = optional(string)
      service_label           = optional(string)
      source_ip_ranges        = optional(list(string))
      allow_psc_global_access = optional(bool)
      no_automate_dns_zone    = optional(bool)
      ip_version              = optional(string)
      region                  = optional(string)
      recreate_closed_psc     = optional(string)
      service_directory_registrations = optional(object({
        namespace = optional(string)
        service   = optional(string)
      }))
      metadata_filters = optional(object({
        filter_match_criteria = optional(string)
        filter_labels = optional(list(object({
          name  = optional(string)
          value = optional(string)
        })))
      }))
    })))
    health_check = optional(map(object({
      name                = string
      check_interval_sec  = optional(string)
      description         = optional(string)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      timeout_sec         = optional(number)
      region              = optional(string)
      project             = optional(string)
      log_config = optional(object({
        enable = optional(bool)
      }))
      http_health_check = optional(object({
        host               = optional(string)
        request_path       = optional(string)
        response           = optional(string)
        port               = optional(number)
        port_name          = optional(string)
        proxy_header       = optional(string)
        port_specification = optional(string)
      }))
      https_health_check = optional(object({
        host               = optional(string)
        request_path       = optional(string)
        response           = optional(string)
        port               = optional(number)
        port_name          = optional(string)
        proxy_header       = optional(string)
        port_specification = optional(string)
      }))
      tcp_health_check = optional(object({
        request            = optional(string)
        response           = optional(string)
        port               = optional(number)
        port_name          = optional(string)
        proxy_header       = optional(string)
        port_specification = optional(string)
      }))
      ssl_health_check = optional(object({
        request            = optional(string)
        response           = optional(string)
        port               = optional(number)
        port_name          = optional(string)
        proxy_header       = optional(string)
        port_specification = optional(string)
      }))
      http2_health_check = optional(object({
        host               = optional(string)
        request_path       = optional(string)
        response           = optional(string)
        port               = optional(number)
        port_name          = optional(string)
        proxy_header       = optional(string)
        port_specification = optional(string)
      }))
      grpc_health_check = optional(object({
        port               = optional(number)
        port_name          = optional(string)
        port_specification = optional(string)
        grpc_service_name  = optional(string)
      }))
    })))
    url_map = optional(map(object({
      region          = optional(string)
      name            = optional(string)
      default_service = optional(string)
      description     = optional(string)
      project         = optional(string)
      host_rule = optional(list(object({
        description  = optional(string)
        hosts        = optional(list(string))
        path_matcher = optional(string)
      })))
      test = optional(object({
        description = optional(string)
        host        = optional(string)
        path        = optional(string)
        service     = optional(string)
      }))
      default_url_redirect = optional(object({
        host_redirect          = optional(string)
        https_redirect         = optional(string)
        path_redirect          = optional(string)
        prefix_redirect        = optional(string)
        redirect_response_code = optional(string)
        strip_query            = optional(string)
      }))
      default_route_action = optional(object({
        weighted_backend_services = optional(object({
          backend_service = optional(string)
          weight          = optional(number)
          header_action = optional(object({
            request_headers_to_remove  = optional(list(string))
            response_headers_to_remove = optional(list(string))
            request_headers_to_add = optional(object({
              header_name  = optional(string)
              header_value = optional(string)
              replace      = optional(string)
            }))
            response_headers_to_add = optional(object({
              header_name  = optional(string)
              header_value = optional(string)
              replace      = optional(string)
            }))
          }))
        }))
        url_rewrite = optional(object({
          path_prefix_rewrite = optional(string)
          host_rewrite        = optional(string)
        }))
        timeout = optional(object({
          seconds = optional(number)
          nanos   = optional(number)
        }))
        retry_policy = optional(object({
          retry_conditions = optional(list(string))
          num_retries      = optional(number)
          per_try_timeout = optional(object({
            seconds = optional(number)
            nanos   = optional(number)
          }))
        }))
        request_mirror_policy = optional(object({
          backend_service = optional(string)
        }))
        cors_policy = optional(object({
          allow_credentials    = optional(bool)
          allow_headers        = optional(list(string))
          allow_methods        = optional(list(string))
          allow_origin_regexes = optional(list(string))
          allow_origins        = optional(list(string))
          disabled             = optional(bool)
          expose_headers       = optional(list(string))
          max_age              = optional(number)
        }))
        fault_injection_policy = optional(object({
          abort = optional(object({
            http_status = optional(string)
            percentage  = optional(number)
          }))
          delay = optional(object({
            percentage = optional(number)
            fixed_delay = optional(object({
              seconds = optional(number)
              nanos   = optional(number)
            }))
          }))
        }))
      }))
      path_matcher = optional(list(object({
        default_service = optional(string)
        name            = optional(string)
        description     = optional(string)
        default_url_redirect = optional(object({
          host_redirect          = optional(string)
          https_redirect         = optional(string)
          path_redirect          = optional(string)
          prefix_redirect        = optional(string)
          redirect_response_code = optional(string)
          strip_query            = optional(string)
        }))
        route_rules = optional(list(object({
          priority = optional(number)
          service  = optional(string)
          route_action = optional(object({
            cors_policy = optional(object({
              allow_credentials    = optional(bool)
              allow_headers        = optional(list(string))
              allow_methods        = optional(list(string))
              allow_origin_regexes = optional(list(string))
              allow_origins        = optional(list(string))
              disabled             = optional(bool)
              expose_headers       = optional(list(string))
              max_age              = optional(number)
            }))
            fault_injection_policy = optional(object({
              abort = optional(object({
                http_status = optional(string)
                percentage  = optional(number)
              }))
              delay = optional(object({
                percentage = optional(number)
                fixed_delay = optional(object({
                  seconds = optional(number)
                  nanos   = optional(number)
                }))
              }))
            }))
          }))
          url_redirect = optional(object({
            host_redirect          = optional(string)
            https_redirect         = optional(string)
            path_redirect          = optional(string)
            prefix_redirect        = optional(string)
            redirect_response_code = optional(string)
            strip_query            = optional(string)
          }))
        })))
        match_rules = optional(list(object({
          full_path_match = optional(string)
          ignore_case     = optional(bool)
          prefix_match    = optional(string)
          regex_match     = optional(string)
          header_matches = optional(list(object({
            exact_match   = optional(string)
            header_name   = optional(string)
            invert_match  = optional(string)
            prefix_match  = optional(string)
            present_match = optional(string)
            regex_match   = optional(string)
            suffix_match  = optional(string)
            range_match = optional(object({
              range_start = optional(number)
              range_end   = optional(number)
            }))
          })))
          metadata_filters = optional(object({
            filter_match_criteria = optional(string)
            filter_labels = optional(list(object({
              name  = optional(string)
              value = optional(string)
            })))
          }))
          query_parameter_matches = optional(list(object({
            exact_match   = optional(string)
            name          = optional(string)
            present_match = optional(string)
            regex_match   = optional(string)
          })))
        })))
        header_action = optional(object({
          request_headers_to_remove  = optional(list(string))
          response_headers_to_remove = optional(list(string))
          request_headers_to_add = optional(object({
            header_name  = optional(string)
            header_value = optional(string)
            replace      = optional(string)
          }))
          response_headers_to_add = optional(object({
            header_name  = optional(string)
            header_value = optional(string)
            replace      = optional(string)
          }))
        }))
        path_rule = optional(list(object({
          service = optional(string)
          paths   = optional(list(string))
          url_redirect = optional(object({
            host_redirect          = optional(string)
            https_redirect         = optional(string)
            path_redirect          = optional(string)
            prefix_redirect        = optional(string)
            redirect_response_code = optional(string)
            strip_query            = optional(string)
          }))
          route_action = optional(object({
            cors_policy = optional(object({
              allow_credentials    = optional(bool)
              allow_headers        = optional(list(string))
              allow_methods        = optional(list(string))
              allow_origin_regexes = optional(list(string))
              allow_origins        = optional(list(string))
              disabled             = optional(bool)
              expose_headers       = optional(list(string))
              max_age              = optional(number)
            }))
            fault_injection_policy = optional(object({
              abort = optional(object({
                http_status = optional(string)
                percentage  = optional(number)
              }))
              delay = optional(object({
                percentage = optional(number)
                fixed_delay = optional(object({
                  seconds = optional(number)
                  nanos   = optional(number)
                }))
              }))
            }))
          }))
        })))
      })))
    })))
  })
  default = {}
}

variable "gclb_registry_json_configuration_file" {
  description = "JSON configuration file for GCP Load Balancers"
  type        = string
  default     = "gcp-load-balancer.json"
}

variable "gclb_registry_yaml_configuration_file" {
  description = "YAML configuration file for GCP Load Balancers"
  type        = string
  default     = "gcp-load-balancer.yaml"
}


locals {
  #
  # Support for JSON, YAML and variable configuration
  #
  gclb_registry_json_configuration = fileexists("${path.root}/${var.gclb_registry_json_configuration_file}") ? jsondecode(file("${path.root}/${var.gclb_registry_json_configuration_file}")) : {}
  gclb_registry_yaml_configuration = fileexists("${path.root}/${var.gclb_registry_yaml_configuration_file}") ? yamldecode(file("${path.root}/${var.gclb_registry_yaml_configuration_file}")) : {}

  lb_backend_service = merge(
    coalesce(try(var.gclb.backend, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.backend, {}),
    try(local.gclb_registry_yaml_configuration.gclb.backend, {}),
  )
  lb_compute_address = merge(
    coalesce(try(var.gclb.address, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.address, {}),
    try(local.gclb_registry_yaml_configuration.gclb.address, {}),
  )
  lb_forwarding_rule = merge(
    coalesce(try(var.gclb.forwarding_rule, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.forwarding_rule, {}),
    try(local.gclb_registry_yaml_configuration.gclb.forwarding_rule, {}),
  )
  lb_health_check = merge(
    coalesce(try(var.gclb.health_check, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.health_check, {}),
    try(local.gclb_registry_yaml_configuration.gclb.health_check, {}),
  )
  lb_url_map = merge(
    coalesce(try(var.gclb.url_map, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.url_map, {}),
    try(local.gclb_registry_yaml_configuration.gclb.url_map, {}),
  )
  lb_certificate = merge(
    coalesce(try(var.gclb.certificate, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.certificate, {}),
    try(local.gclb_registry_yaml_configuration.gclb.certificate, {}),
  )
  lb_proxy = merge(
    coalesce(try(var.gclb.proxy, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.proxy, {}),
    try(local.gclb_registry_yaml_configuration.gclb.proxy, {}),
  )
  lb_ssl_policy = merge(
    coalesce(try(var.gclb.ssl_policy, {}), {}),
    try(local.gclb_registry_json_configuration.gclb.ssl_policy, {}),
    try(local.gclb_registry_yaml_configuration.gclb.ssl_policy, {}),
  )

  #
  # GCP LB Backend Services
  #
  gcp_lb_backend_service = flatten([
    for backend_id, backend in coalesce(try(local.lb_backend_service, null), {}) : merge(
      backend,
      {
        resource_index = join("_", [backend_id])
      }
    )
  ])

  #
  # GCP LB Address allocations
  #
  gcp_lb_compute_address = flatten([
    for address_id, address in coalesce(try(local.lb_compute_address, null), {}) : merge(
      address,
      {
        resource_index = join("_", [address_id])
      }
    )
  ])

  #
  # GCP LB Address DNS records
  #
  gcp_lb_compute_address_dns = flatten([
    for address_id, address in coalesce(try(local.lb_compute_address, null), {}) : [
      for dns_address in coalesce(address.dns, []) : merge(
        dns_address,
        {
          address_id     = address_id
          resource_index = join("_", [address_id, dns_address.managed_zone, dns_address.name])
        }
      )
    ]
  ])

  #
  # GCP LB Forwarding rules
  #
  gcp_lb_forwarding_rule = flatten([
    for rule_id, rule in coalesce(try(local.lb_forwarding_rule, null), {}) : merge(
      rule,
      {
        resource_index = join("_", [rule_id])
      }
    )
  ])

  #
  # GCP LB Health checks
  #
  gcp_lb_health_check = flatten([
    for health_check_id, health_check in coalesce(try(local.lb_health_check, null), {}) : merge(
      health_check,
      {
        resource_index = join("_", [health_check_id])
      }
    )
  ])

  #
  # GCP LB URL Maps
  #
  gcp_lb_url_map = flatten([
    for url_map_id, url_map in coalesce(try(local.lb_url_map, null), {}) : merge(
      url_map,
      {
        resource_index = join("_", [url_map_id])
      }
    )
  ])

  #
  # GCP LB Certificates
  #
  gcp_lb_certificate = flatten([
    for certificate_id, certificate in coalesce(try(local.lb_certificate, null), {}) : merge(
      certificate,
      {
        resource_index = join("_", [certificate_id])
      }
    )
  ])

  #
  # GCP LB Proxy Configurations
  #
  gcp_lb_proxy = flatten([
    for proxy_id, proxy in coalesce(try(local.lb_proxy, null), {}) : merge(
      proxy,
      {
        resource_index = join("_", [proxy_id])
      }
    )
  ])

  #
  # GCP LB SSL Policies
  #
  gcp_lb_ssl_policy = flatten([
    for ssl_policy_id, ssl_policy in coalesce(try(local.lb_ssl_policy, null), {}) : merge(
      ssl_policy,
      {
        resource_index = join("_", [ssl_policy_id])
      }
    )
  ])
}
