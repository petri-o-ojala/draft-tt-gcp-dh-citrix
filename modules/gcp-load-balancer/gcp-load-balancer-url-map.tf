#
# GCP Load Balancer URL Maps
#

resource "google_compute_region_url_map" "lz" {
  #
  # GCLB URL Map (Regional)
  #
  for_each = {
    for url_map in local.gcp_lb_url_map : url_map.resource_index => url_map
    if url_map.region != null
  }

  name            = each.value.name
  default_service = each.value.default_service == null ? null : lookup(local.google_compute_backend_service, each.value.default_service, null) == null ? each.value.default_service : local.google_compute_backend_service[each.value.default_service].self_link
  description     = each.value.description
  region          = each.value.region
  project         = each.value.project

  dynamic "host_rule" {
    # (Optional) The list of HostRules to use against the URL.
    for_each = coalesce(each.value.host_rule, [])

    content {
      description  = host_rule.value.description
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    # (Optional) The list of named PathMatchers to use against the URL.
    for_each = coalesce(each.value.path_matcher, [])

    content {
      description     = path_matcher.value.description
      default_service = path_matcher.value.default_service == null ? null : lookup(local.google_compute_backend_service, path_matcher.value.default_service, null) == null ? path_matcher.value.default_service : local.google_compute_backend_service[path_matcher.value.default_service].self_link
      name            = path_matcher.value.name

      dynamic "default_url_redirect" {
        # (Optional) When none of the specified hostRules match, the request is redirected to a URL specified by defaultUrlRedirect. 
        # If defaultUrlRedirect is specified, defaultService or defaultRouteAction must not be set.
        for_each = try(path_matcher.value.default_url_redirect, null) == null ? [] : [1]

        content {
          host_redirect          = path_matcher.value.default_url_redirect.host_redirect
          https_redirect         = path_matcher.value.default_url_redirect.https_redirect
          path_redirect          = path_matcher.value.default_url_redirect.path_redirect
          prefix_redirect        = path_matcher.value.default_url_redirect.prefix_redirect
          redirect_response_code = path_matcher.value.default_url_redirect.redirect_response_code
          strip_query            = path_matcher.value.default_url_redirect.strip_query
        }
      }

      dynamic "route_rules" {
        # (Optional) The list of ordered HTTP route rules. Use this list instead of pathRules when advanced route matching 
        # and routing actions are desired. The order of specifying routeRules matters: the first rule that matches will 
        # cause its specified routing action to take effect. Within a given pathMatcher, only one of pathRules or 
        # routeRules must be set. routeRules are not supported in UrlMaps intended for External load balancers. 
        for_each = coalesce(path_matcher.value.route_rules, [])

        content {
          priority = route_rules.value.priority
          service  = route_rules.value.service

          dynamic "route_action" {
            # (Optional) In response to a matching matchRule, the load balancer performs advanced routing actions like URL rewrites, header transformations, etc. prior to forwarding the request to the selected backend. If routeAction specifies any weightedBackendServices, service must not be set. Conversely if service is set, routeAction cannot contain any weightedBackendServices. Only one of routeAction or urlRedirect must be set. 
            for_each = try(route_rules.value.route_action, null) == null ? [] : [1]

            content {
              dynamic "cors_policy" {
                # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation 
                # for Cross Origin Resource Sharing
                for_each = try(route_rules.value.route_action.cors_policy, null) == null ? [] : [1]

                content {
                  allow_credentials    = route_rules.value.route_action.cors_policy.allow_credentials
                  allow_headers        = route_rules.value.route_action.cors_policy.allow_headers
                  allow_methods        = route_rules.value.route_action.cors_policy.allow_methods
                  allow_origin_regexes = route_rules.value.route_action.cors_policy.allow_origin_regexes
                  allow_origins        = route_rules.value.route_action.cors_policy.allow_origins
                  disabled             = route_rules.value.route_action.cors_policy.disabled
                  expose_headers       = route_rules.value.route_action.cors_policy.expose_headers
                  max_age              = route_rules.value.route_action.cors_policy.max_age
                }
              }

              dynamic "fault_injection_policy" {
                # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients 
                # to backend service failure. As part of fault injection, when clients send requests to a backend service, 
                # delays can be introduced by Loadbalancer on a percentage of requests before sending those request to 
                # the backend service. Similarly requests from clients can be aborted by the Loadbalancer for a 
                # percentage of requests. timeout and retry_policy will be ignored by clients that are configured 
                # with a fault_injection_policy.
                for_each = try(route_rules.value.route_action.fault_injection_policy, null) == null ? [] : [1]

                content {
                  dynamic "abort" {
                    # (Optional) The specification for how client requests are aborted as part of fault injection.
                    for_each = try(route_rules.value.route_action.fault_injection_policy.abort, null) == null ? [] : [1]

                    content {
                      http_status = route_rules.value.route_action.fault_injection_policy.abort.http_status
                      percentage  = route_rules.value.route_action.fault_injection_policy.abort.percentage
                    }
                  }

                  dynamic "delay" {
                    # (Optional) The specification for how client requests are delayed as part of fault injection, 
                    # before being sent to a backend service.
                    for_each = try(route_rules.value.route_action.fault_injection_policy.delay, null) == null ? [] : [1]

                    content {
                      percentage = route_rules.value.route_action.fault_injection_policy.delay.percentage

                      dynamic "fixed_delay" {
                        # (Optional) Specifies the value of the fixed delay interval
                        for_each = try(route_rules.value.route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                        content {
                          seconds = route_rules.value.route_action.fault_injection_policy.delay.fixed_delay.seconds
                          nanos   = route_rules.value.route_action.fault_injection_policy.delay.fixed_delay.nanos
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          dynamic "url_redirect" {
            #  (Optional) When this rule is matched, the request is redirected to a URL specified by urlRedirect. If urlRedirect is specified, service or routeAction must not be set. 
            for_each = try(route_rules.value.url_redirect, null) == null ? [] : [1]

            content {
              host_redirect          = route_rules.value.url_redirect.host_redirect
              https_redirect         = route_rules.value.url_redirect.https_redirect
              path_redirect          = route_rules.value.url_redirect.path_redirect
              prefix_redirect        = route_rules.value.url_redirect.prefix_redirect
              redirect_response_code = route_rules.value.url_redirect.redirect_response_code
              strip_query            = route_rules.value.url_redirect.strip_query
            }
          }

          dynamic "match_rules" {
            #  (Optional) The rules for determining a match.
            for_each = coalesce(path_matcher.value.match_rules, [])

            content {
              full_path_match = match_rules.value.full_path_match
              ignore_case     = match_rules.value.ignore_case
              prefix_match    = match_rules.value.prefix_match
              regex_match     = match_rules.value.regex_match

              dynamic "header_matches" {
                # (Optional) Specifies a list of header match criteria, all of which must match corresponding headers in the request.
                for_each = coalesce(match_rules.value.header_matches, [])

                content {
                  exact_match   = header_matches.value.exact_match
                  header_name   = header_matches.value.header_name
                  invert_match  = header_matches.value.invert_match
                  prefix_match  = header_matches.value.prefix_match
                  present_match = header_matches.value.present_match
                  regex_match   = header_matches.value.regex_match
                  suffix_match  = header_matches.value.suffix_match

                  dynamic "range_match" {
                    # (Optional) The header value must be an integer and its value must be in the range specified in rangeMatch. 
                    # If the header does not contain an integer, number or is empty, the match fails. 
                    for_each = try(header_matches.value.range_match, null) == null ? [] : [1]

                    content {
                      range_end   = header_matches.value.range_match.range_end
                      range_start = header_matches.value.range_match.rangerange_start_end
                    }
                  }
                }
              }

              dynamic "metadata_filters" {
                # (Optional) Opaque filter criteria used by Loadbalancer to restrict routing configuration to a limited set xDS 
                # compliant clients. In their xDS requests to Loadbalancer, xDS clients present node metadata. If a match 
                # takes place, the relevant routing configuration is made available to those proxies. For each metadataFilter 
                # in this list, if its filterMatchCriteria is set to MATCH_ANY, at least one of the filterLabels must match 
                # the corresponding label provided in the metadata. If its filterMatchCriteria is set to MATCH_ALL, then all 
                # of its filterLabels must match with corresponding labels in the provided metadata. metadataFilters specified
                #  here can be overrides those specified in ForwardingRule that refers to this UrlMap. metadataFilters only 
                # applies to Loadbalancers that have their loadBalancingScheme set to INTERNAL_SELF_MANAGED. 
                for_each = try(match_rules.value.metadata_filters, null) == null ? [] : [1]

                content {
                  filter_match_criteria = match_rules.value.metadata_filters.filter_match_criteria

                  dynamic "filter_labels" {
                    # (Optional) The header value must be an integer and its value must be in the range specified in rangeMatch. 
                    # If the header does not contain an integer, number or is empty, the match fails. 
                    for_each = coalesce(match_rules.value.metadata_filters.filter_labels, [])

                    content {
                      name  = filter_labels.value.name
                      value = filter_labels.value.value
                    }
                  }
                }
              }

              dynamic "query_parameter_matches" {
                # (Optional) Specifies a list of query parameter match criteria, all of which must match corresponding query parameters in the request.
                for_each = coalesce(match_rules.value.query_parameter_matches, [])

                content {
                  exact_match   = query_parameter_matches.value.exact_match
                  name          = query_parameter_matches.value.name
                  present_match = query_parameter_matches.value.present_match
                  regex_match   = query_parameter_matches.value.regex_match
                }
              }
            }
          }

          dynamic "header_action" {
            # (Optional) Specifies changes to request and response headers that need to take effect for the selected backendService. 
            # The headerAction specified here are applied before the matching pathMatchers[].headerAction and after 
            # pathMatchers[].routeRules[].r outeAction.weightedBackendService.backendServiceWeightAction[].headerAction
            for_each = try(route_rules.value.header_action, null) == null ? [] : [1]

            content {
              request_headers_to_remove  = route_rules.value.header_action.request_headers_to_remove
              response_headers_to_remove = route_rules.value.header_action.response_headers_to_remove

              dynamic "request_headers_to_add" {
                # (Optional) Headers to add to a matching request prior to forwarding the request to the backendService. 
                for_each = try(route_rules.value.header_action.request_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = route_rules.value.header_action.request_headers_to_add.header_name
                  header_value = route_rules.value.header_action.request_headers_to_add.header_value
                  replace      = route_rules.value.header_action.request_headers_to_add.replace
                }
              }

              dynamic "response_headers_to_add" {
                # (Optional) Headers to add the response prior to sending the response back to the client.
                for_each = try(route_rules.value.header_action.response_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = route_rules.value.header_action.response_headers_to_add.header_name
                  header_value = route_rules.value.header_action.response_headers_to_add.header_value
                  replace      = route_rules.value.header_action.response_headers_to_add.replace
                }
              }
            }
          }
        }
      }

      dynamic "path_rule" {
        # (Optional) The list of path rules. Use this list instead of routeRules when routing based on simple path matching 
        # is all that's required. The order by which path rules are specified does not matter. Matches are always done on the 
        # longest-path-first basis. For example: a pathRule with a path /a/b/c/* will match before /a/b/* irrespective of 
        # the order in which those paths appear in this list. Within a given pathMatcher, only one of pathRules or 
        # routeRules must be set.
        for_each = coalesce(path_matcher.value.path_rule, [])

        content {
          service = path_rule.value.service
          paths   = path_rule.value.paths

          dynamic "url_redirect" {
            # (Optional) When a path pattern is matched, the request is redirected to a URL specified by urlRedirect. If 
            # urlRedirect is specified, service or routeAction must not be set. 
            for_each = try(path_rule.value.url_redirect, null) == null ? [] : [1]

            content {
              host_redirect          = path_rule.value.url_redirect.host_redirect
              https_redirect         = path_rule.value.url_redirect.https_redirect
              path_redirect          = path_rule.value.url_redirect.path_redirect
              prefix_redirect        = path_rule.value.url_redirect.prefix_redirect
              redirect_response_code = path_rule.value.url_redirect.redirect_response_code
              strip_query            = path_rule.value.url_redirect.strip_query
            }
          }

          dynamic "route_action" {
            for_each = try(path_rule.value.route_action, null) == null ? [] : [1]

            content {
              dynamic "cors_policy" {
                # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation 
                # for Cross Origin Resource Sharing
                for_each = try(path_rule.value.route_action.cors_policy, null) == null ? [] : [1]

                content {
                  allow_credentials    = path_rule.value.route_action.cors_policy.allow_credentials
                  allow_headers        = path_rule.value.route_action.cors_policy.allow_headers
                  allow_methods        = path_rule.value.route_action.cors_policy.allow_methods
                  allow_origin_regexes = path_rule.value.route_action.cors_policy.allow_origin_regexes
                  allow_origins        = path_rule.value.route_action.cors_policy.allow_origins
                  disabled             = path_rule.value.route_action.cors_policy.disabled
                  expose_headers       = path_rule.value.route_action.cors_policy.expose_headers
                  max_age              = path_rule.value.route_action.cors_policy.max_age
                }
              }

              dynamic "fault_injection_policy" {
                # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients 
                # to backend service failure. As part of fault injection, when clients send requests to a backend service, 
                # delays can be introduced by Loadbalancer on a percentage of requests before sending those request to 
                # the backend service. Similarly requests from clients can be aborted by the Loadbalancer for a 
                # percentage of requests. timeout and retry_policy will be ignored by clients that are configured 
                # with a fault_injection_policy.
                for_each = try(path_rule.value.route_action.fault_injection_policy, null) == null ? [] : [1]

                content {
                  dynamic "abort" {
                    # (Optional) The specification for how client requests are aborted as part of fault injection.
                    for_each = try(path_rule.value.route_action.fault_injection_policy.abort, null) == null ? [] : [1]

                    content {
                      http_status = path_rule.value.route_action.fault_injection_policy.abort.http_status
                      percentage  = path_rule.value.route_action.fault_injection_policy.abort.percentage
                    }
                  }

                  dynamic "delay" {
                    # (Optional) The specification for how client requests are delayed as part of fault injection, 
                    # before being sent to a backend service.
                    for_each = try(path_rule.value.route_action.fault_injection_policy.delay, null) == null ? [] : [1]

                    content {
                      percentage = path_rule.value.route_action.fault_injection_policy.delay.percentage

                      dynamic "fixed_delay" {
                        # (Optional) Specifies the value of the fixed delay interval
                        for_each = try(path_rule.value.route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                        content {
                          seconds = path_rule.value.route_action.fault_injection_policy.delay.fixed_delay.seconds
                          nanos   = path_rule.value.route_action.fault_injection_policy.delay.fixed_delay.nanos
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "test" {
    # (Optional) The list of expected URL mappings. Requests to update this UrlMap will succeed only if all of the test cases pass.
    for_each = try(each.value.test, null) == null ? [] : [1]

    content {
      description = each.value.test.description
      host        = each.value.test.host
      path        = each.value.test.path
      service     = each.value.test.service
    }
  }

  dynamic "default_url_redirect" {
    # (Optional) When none of the specified hostRules match, the request is redirected to a URL specified by defaultUrlRedirect. If
    #  defaultUrlRedirect is specified, defaultService or defaultRouteAction must not be set.
    for_each = try(each.value.default_url_redirect, null) == null ? [] : [1]

    content {
      host_redirect          = each.value.default_url_redirect.host_redirect
      https_redirect         = each.value.default_url_redirect.https_redirect
      path_redirect          = each.value.default_url_redirect.path_redirect
      prefix_redirect        = each.value.default_url_redirect.prefix_redirect
      redirect_response_code = each.value.default_url_redirect.redirect_response_code
      strip_query            = each.value.default_url_redirect.strip_query
    }
  }

  dynamic "default_route_action" {
    # (Optional) defaultRouteAction takes effect when none of the hostRules match. The load balancer performs advanced routing actions,
    # such as URL rewrites and header transformations, before forwarding the request to the selected backend. If defaultRouteAction 
    # specifies any weightedBackendServices, defaultService must not be set. Conversely if defaultService is set, defaultRouteAction 
    # cannot contain any weightedBackendServices. Only one of defaultRouteAction or defaultUrlRedirect must be set. URL maps for 
    # Classic external HTTP(S) load balancers only support the urlRewrite action within defaultRouteAction. defaultRouteAction has 
    # no effect when the URL map is bound to a target gRPC proxy that has the validateForProxyless field set to true.
    for_each = try(each.value.default_route_action, null) == null ? [] : [1]

    content {
      dynamic "weighted_backend_services" {
        # (Optional) A list of weighted backend services to send traffic to when a route match occurs. The weights determine the 
        # fraction of traffic that flows to their corresponding backend service. If all traffic needs to go to a single backend 
        # service, there must be one weightedBackendService with weight set to a non-zero number. After a backend service is 
        # identified and before forwarding the request to the backend service, advanced routing actions such as URL rewrites 
        # and header transformations are applied depending on additional settings specified in this HttpRouteAction.
        for_each = try(each.value.default_route_action.weighted_backend_services, null) == null ? [] : [1]

        content {
          backend_service = each.value.default_route_action.weighted_backend_services.backend_service
          weight          = each.value.default_route_action.weighted_backend_services.weight

          dynamic "header_action" {
            # (Optional) Specifies changes to request and response headers that need to take effect for the selected backendService. 
            # headerAction specified here take effect before headerAction in the enclosing HttpRouteRule, PathMatcher and UrlMap.
            # headerAction is not supported for load balancers that have their loadBalancingScheme set to EXTERNAL. Not supported
            #  when the URL map is bound to a target gRPC proxy that has validateForProxyless field set to true. 
            for_each = try(each.value.default_route_action.weighted_backend_services.header_action, null) == null ? [] : [1]

            content {
              request_headers_to_remove  = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_remove
              response_headers_to_remove = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_remove

              dynamic "request_headers_to_add" {
                # (Optional) Headers to add to a matching request prior to forwarding the request to the backendService. 
                for_each = try(each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.header_name
                  header_value = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.header_value
                  replace      = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.replace
                }
              }

              dynamic "response_headers_to_add" {
                # (Optional) Headers to add the response prior to sending the response back to the client.
                for_each = try(each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.header_name
                  header_value = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.header_value
                  replace      = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.replace
                }
              }
            }
          }
        }
      }

      dynamic "url_rewrite" {
        # (Optional) The spec to modify the URL of the request, before forwarding the request to the matched service. urlRewrite is the 
        # only action supported in UrlMaps for external HTTP(S) load balancers. Not supported when the URL map is bound to a target
        # gRPC proxy that has the validateForProxyless field set to true.
        for_each = try(each.value.default_route_action.url_rewrite, null) == null ? [] : [1]

        content {
          path_prefix_rewrite = each.value.default_route_action.url_rewrite.path_prefix_rewrite
          host_rewrite        = each.value.default_route_action.url_rewrite.host_rewrite
        }
      }

      dynamic "timeout" {
        # (Optional) Specifies the timeout for the selected route. Timeout is computed from the time the request has been fully processed 
        # (known as end-of-stream) up until the response has been processed. Timeout includes all retries. If not specified, this field
        #  uses the largest timeout among all backend services associated with the route. Not supported when the URL map is bound to a
        #  target gRPC proxy that has validateForProxyless field set to true.
        for_each = try(each.value.default_route_action.timeout, null) == null ? [] : [1]

        content {
          seconds = each.value.default_route_action.timeout.seconds
          nanos   = each.value.default_route_action.timeout.nanos
        }
      }

      dynamic "retry_policy" {
        # (Optional) Specifies the retry policy associated with this route.
        for_each = try(each.value.default_route_action.retry_policy, null) == null ? [] : [1]

        content {
          retry_conditions = each.value.default_route_action.retry_policy.retry_conditions
          num_retries      = each.value.default_route_action.retry_policy.num_retries

          dynamic "per_try_timeout" {
            # (Optional) Specifies a non-zero timeout per retry attempt. If not specified, will use the timeout set in HttpRouteAction.
            # If timeout in HttpRouteAction is not set, will use the largest timeout among all backend services associated with the route.
            for_each = try(each.value.default_route_action.per_try_timeout, null) == null ? [] : [1]

            content {
              seconds = each.value.default_route_action.per_try_timeout.seconds
              nanos   = each.value.default_route_action.per_try_timeout.nanos
            }
          }
        }
      }

      dynamic "request_mirror_policy" {
        # (Optional) Specifies the policy on how requests intended for the route's backends are shadowed to a separate mirrored backend 
        # service. The load balancer does not wait for responses from the shadow service. Before sending traffic to the shadow service,
        # the host / authority header is suffixed with -shadow. Not supported when the URL map is bound to a target gRPC proxy that
        # has the validateForProxyless field set to true.
        for_each = try(each.value.default_route_actionrequest_mirror_policy, null) == null ? [] : [1]

        content {
          backend_service = each.value.default_route_actionrequest_mirror_policy.backend_service
        }
      }

      dynamic "cors_policy" {
        # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation for Cross Origin Resource Sharing
        for_each = try(each.value.default_route_action.cors_policy, null) == null ? [] : [1]

        content {
          allow_origins        = each.value.default_route_action.cors_policy.allow_origins
          allow_origin_regexes = each.value.default_route_action.cors_policy.allow_origin_regexes
          allow_methods        = each.value.default_route_action.cors_policy.allow_methods
          allow_headers        = each.value.default_route_action.cors_policy.allow_headers
          expose_headers       = each.value.default_route_action.cors_policy.expose_headers
          max_age              = each.value.default_route_action.cors_policy.max_age
          allow_credentials    = each.value.default_route_action.cors_policy.allow_credentials
          disabled             = each.value.default_route_action.cors_policy.disabled

        }
      }

      dynamic "fault_injection_policy" {
        # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients to backend service failure. As part of fault injection, when clients send requests to a backend service, delays can be introduced by a load balancer on a percentage of requests before sending those requests to the backend service. Similarly requests from clients can be aborted by the load balancer for a percentage of requests. timeout and retryPolicy is ignored by clients that are configured with a faultInjectionPolicy if: 1. The traffic is generated by fault injection AND 2. The fault injection is not a delay fault injection. Fault injection is not supported with the global external HTTP(S) load balancer (classic). To see which load balancers support fault injection, see Load balancing: Routing and traffic management features.
        for_each = try(each.value.default_route_action.fault_injection_policy, null) == null ? [] : [1]

        content {
          dynamic "abort" {
            # (Optional) The specification for how client requests are aborted as part of fault injection.
            for_each = try(each.value.default_route_action.fault_injection_policy.abort, null) == null ? [] : [1]

            content {
              http_status = each.value.default_route_action.fault_injection_policy.abort.http_status
              percentage  = each.value.default_route_action.fault_injection_policy.abort.percentage
            }
          }

          dynamic "delay" {
            # (Optional) The specification for how client requests are delayed as part of fault injection, 
            # before being sent to a backend service.
            for_each = try(each.value.default_route_action.fault_injection_policy.delay, null) == null ? [] : [1]

            content {
              percentage = each.value.default_route_action.fault_injection_policy.delay.percentage

              dynamic "fixed_delay" {
                # (Optional) Specifies the value of the fixed delay interval
                for_each = try(each.value.default_route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                content {
                  seconds = each.value.default_route_action.fault_injection_policy.delay.fixed_delay.seconds
                  nanos   = each.value.default_route_action.fault_injection_policy.delay.fixed_delay.nanos
                }
              }
            }
          }

        }
      }
    }
  }
}

resource "google_compute_url_map" "lz" {
  #
  # GCLB URL Map (Global)
  #
  for_each = {
    for url_map in local.gcp_lb_url_map : url_map.resource_index => url_map
    if url_map.region == null
  }

  name            = each.value.name
  default_service = each.value.default_service == null ? null : lookup(local.google_compute_backend_service, each.value.default_service, null) == null ? each.value.default_service : local.google_compute_backend_service[each.value.default_service].self_link
  description     = each.value.description
  project         = each.value.project

  dynamic "host_rule" {
    # (Optional) The list of HostRules to use against the URL.
    for_each = coalesce(each.value.host_rule, [])

    content {
      description  = host_rule.value.description
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    # (Optional) The list of named PathMatchers to use against the URL.
    for_each = coalesce(each.value.path_matcher, [])

    content {
      default_service = path_matcher.value.default_service == null ? null : lookup(local.google_compute_backend_service, path_matcher.value.default_service, null) == null ? path_matcher.value.default_service : local.google_compute_backend_service[path_matcher.value.default_service].self_link
      description     = path_matcher.value.description
      name            = path_matcher.value.name

      dynamic "default_url_redirect" {
        # (Optional) When none of the specified hostRules match, the request is redirected to a URL specified by defaultUrlRedirect. 
        # If defaultUrlRedirect is specified, defaultService or defaultRouteAction must not be set.
        for_each = try(path_matcher.value.default_url_redirect, null) == null ? [] : [1]

        content {
          host_redirect          = path_matcher.value.default_url_redirect.host_redirect
          https_redirect         = path_matcher.value.default_url_redirect.https_redirect
          path_redirect          = path_matcher.value.default_url_redirect.path_redirect
          prefix_redirect        = path_matcher.value.default_url_redirect.prefix_redirect
          redirect_response_code = path_matcher.value.default_url_redirect.redirect_response_code
          strip_query            = path_matcher.value.default_url_redirect.strip_query
        }
      }

      dynamic "route_rules" {
        # (Optional) The list of ordered HTTP route rules. Use this list instead of pathRules when advanced route matching 
        # and routing actions are desired. The order of specifying routeRules matters: the first rule that matches will 
        # cause its specified routing action to take effect. Within a given pathMatcher, only one of pathRules or 
        # routeRules must be set. routeRules are not supported in UrlMaps intended for External load balancers. 
        for_each = coalesce(path_matcher.value.route_rules, [])

        content {
          priority = route_rules.value.priority
          service  = route_rules.value.service

          dynamic "route_action" {
            # (Optional) In response to a matching matchRule, the load balancer performs advanced routing actions like URL rewrites, header transformations, etc. prior to forwarding the request to the selected backend. If routeAction specifies any weightedBackendServices, service must not be set. Conversely if service is set, routeAction cannot contain any weightedBackendServices. Only one of routeAction or urlRedirect must be set. 
            for_each = try(route_rules.value.route_action, null) == null ? [] : [1]

            content {
              dynamic "cors_policy" {
                # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation 
                # for Cross Origin Resource Sharing
                for_each = try(route_rules.value.route_action.cors_policy, null) == null ? [] : [1]

                content {
                  allow_credentials    = route_rules.value.route_action.cors_policy.allow_credentials
                  allow_headers        = route_rules.value.route_action.cors_policy.allow_headers
                  allow_methods        = route_rules.value.route_action.cors_policy.allow_methods
                  allow_origin_regexes = route_rules.value.route_action.cors_policy.allow_origin_regexes
                  allow_origins        = route_rules.value.route_action.cors_policy.allow_origins
                  disabled             = route_rules.value.route_action.cors_policy.disabled
                  expose_headers       = route_rules.value.route_action.cors_policy.expose_headers
                  max_age              = route_rules.value.route_action.cors_policy.max_age
                }
              }

              dynamic "fault_injection_policy" {
                # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients 
                # to backend service failure. As part of fault injection, when clients send requests to a backend service, 
                # delays can be introduced by Loadbalancer on a percentage of requests before sending those request to 
                # the backend service. Similarly requests from clients can be aborted by the Loadbalancer for a 
                # percentage of requests. timeout and retry_policy will be ignored by clients that are configured 
                # with a fault_injection_policy.
                for_each = try(route_rules.value.route_action.fault_injection_policy, null) == null ? [] : [1]

                content {
                  dynamic "abort" {
                    # (Optional) The specification for how client requests are aborted as part of fault injection.
                    for_each = try(route_rules.value.route_action.fault_injection_policy.abort, null) == null ? [] : [1]

                    content {
                      http_status = route_rules.value.route_action.fault_injection_policy.abort.http_status
                      percentage  = route_rules.value.route_action.fault_injection_policy.abort.percentage
                    }
                  }

                  dynamic "delay" {
                    # (Optional) The specification for how client requests are delayed as part of fault injection, 
                    # before being sent to a backend service.
                    for_each = try(route_rules.value.route_action.fault_injection_policy.delay, null) == null ? [] : [1]

                    content {
                      percentage = route_rules.value.route_action.fault_injection_policy.delay.percentage

                      dynamic "fixed_delay" {
                        # (Optional) Specifies the value of the fixed delay interval
                        for_each = try(route_rules.value.route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                        content {
                          seconds = route_rules.value.route_action.fault_injection_policy.delay.fixed_delay.seconds
                          nanos   = route_rules.value.route_action.fault_injection_policy.delay.fixed_delay.nanos
                        }
                      }
                    }
                  }
                }
              }
            }
          }

          dynamic "url_redirect" {
            #  (Optional) When this rule is matched, the request is redirected to a URL specified by urlRedirect. If urlRedirect is specified, service or routeAction must not be set. 
            for_each = try(route_rules.value.url_redirect, null) == null ? [] : [1]

            content {
              host_redirect          = route_rules.value.url_redirect.host_redirect
              https_redirect         = route_rules.value.url_redirect.https_redirect
              path_redirect          = route_rules.value.url_redirect.path_redirect
              prefix_redirect        = route_rules.value.url_redirect.prefix_redirect
              redirect_response_code = route_rules.value.url_redirect.redirect_response_code
              strip_query            = route_rules.value.url_redirect.strip_query
            }
          }

          dynamic "match_rules" {
            #  (Optional) The rules for determining a match.
            for_each = coalesce(path_matcher.value.match_rules, [])

            content {
              full_path_match = match_rules.value.full_path_match
              ignore_case     = match_rules.value.ignore_case
              prefix_match    = match_rules.value.prefix_match
              regex_match     = match_rules.value.regex_match

              dynamic "header_matches" {
                # (Optional) Specifies a list of header match criteria, all of which must match corresponding headers in the request.
                for_each = coalesce(match_rules.value.header_matches, [])

                content {
                  exact_match   = header_matches.value.exact_match
                  header_name   = header_matches.value.header_name
                  invert_match  = header_matches.value.invert_match
                  prefix_match  = header_matches.value.prefix_match
                  present_match = header_matches.value.present_match
                  regex_match   = header_matches.value.regex_match
                  suffix_match  = header_matches.value.suffix_match

                  dynamic "range_match" {
                    # (Optional) The header value must be an integer and its value must be in the range specified in rangeMatch. 
                    # If the header does not contain an integer, number or is empty, the match fails. 
                    for_each = try(header_matches.value.range_match, null) == null ? [] : [1]

                    content {
                      range_end   = header_matches.value.range_match.range_end
                      range_start = header_matches.value.range_match.rangerange_start_end
                    }
                  }
                }
              }

              dynamic "metadata_filters" {
                # (Optional) Opaque filter criteria used by Loadbalancer to restrict routing configuration to a limited set xDS 
                # compliant clients. In their xDS requests to Loadbalancer, xDS clients present node metadata. If a match 
                # takes place, the relevant routing configuration is made available to those proxies. For each metadataFilter 
                # in this list, if its filterMatchCriteria is set to MATCH_ANY, at least one of the filterLabels must match 
                # the corresponding label provided in the metadata. If its filterMatchCriteria is set to MATCH_ALL, then all 
                # of its filterLabels must match with corresponding labels in the provided metadata. metadataFilters specified
                #  here can be overrides those specified in ForwardingRule that refers to this UrlMap. metadataFilters only 
                # applies to Loadbalancers that have their loadBalancingScheme set to INTERNAL_SELF_MANAGED. 
                for_each = try(match_rules.value.metadata_filters, null) == null ? [] : [1]

                content {
                  filter_match_criteria = match_rules.value.metadata_filters.filter_match_criteria

                  dynamic "filter_labels" {
                    # (Optional) The header value must be an integer and its value must be in the range specified in rangeMatch. 
                    # If the header does not contain an integer, number or is empty, the match fails. 
                    for_each = coalesce(match_rules.value.metadata_filters.filter_labels, [])

                    content {
                      name  = filter_labels.value.name
                      value = filter_labels.value.value
                    }
                  }
                }
              }

              dynamic "query_parameter_matches" {
                # (Optional) Specifies a list of query parameter match criteria, all of which must match corresponding query parameters in the request.
                for_each = coalesce(match_rules.value.query_parameter_matches, [])

                content {
                  exact_match   = query_parameter_matches.value.exact_match
                  name          = query_parameter_matches.value.name
                  present_match = query_parameter_matches.value.present_match
                  regex_match   = query_parameter_matches.value.regex_match
                }
              }
            }
          }

          dynamic "header_action" {
            # (Optional) Specifies changes to request and response headers that need to take effect for the selected backendService. 
            # The headerAction specified here are applied before the matching pathMatchers[].headerAction and after 
            # pathMatchers[].routeRules[].r outeAction.weightedBackendService.backendServiceWeightAction[].headerAction
            for_each = try(route_rules.value.header_action, null) == null ? [] : [1]

            content {
              request_headers_to_remove  = route_rules.value.header_action.request_headers_to_remove
              response_headers_to_remove = route_rules.value.header_action.response_headers_to_remove

              dynamic "request_headers_to_add" {
                # (Optional) Headers to add to a matching request prior to forwarding the request to the backendService. 
                for_each = try(route_rules.value.header_action.request_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = route_rules.value.header_action.request_headers_to_add.header_name
                  header_value = route_rules.value.header_action.request_headers_to_add.header_value
                  replace      = route_rules.value.header_action.request_headers_to_add.replace
                }
              }

              dynamic "response_headers_to_add" {
                # (Optional) Headers to add the response prior to sending the response back to the client.
                for_each = try(route_rules.value.header_action.response_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = route_rules.value.header_action.response_headers_to_add.header_name
                  header_value = route_rules.value.header_action.response_headers_to_add.header_value
                  replace      = route_rules.value.header_action.response_headers_to_add.replace
                }
              }
            }
          }
        }
      }

      dynamic "path_rule" {
        # (Optional) The list of path rules. Use this list instead of routeRules when routing based on simple path matching 
        # is all that's required. The order by which path rules are specified does not matter. Matches are always done on the 
        # longest-path-first basis. For example: a pathRule with a path /a/b/c/* will match before /a/b/* irrespective of 
        # the order in which those paths appear in this list. Within a given pathMatcher, only one of pathRules or 
        # routeRules must be set.
        for_each = coalesce(path_matcher.value.path_rule, [])

        content {
          service = path_rule.value.service
          paths   = path_rule.value.paths

          dynamic "url_redirect" {
            # (Optional) When a path pattern is matched, the request is redirected to a URL specified by urlRedirect. If 
            # urlRedirect is specified, service or routeAction must not be set. 
            for_each = try(path_rule.value.url_redirect, null) == null ? [] : [1]

            content {
              host_redirect          = path_rule.value.url_redirect.host_redirect
              https_redirect         = path_rule.value.url_redirect.https_redirect
              path_redirect          = path_rule.value.url_redirect.path_redirect
              prefix_redirect        = path_rule.value.url_redirect.prefix_redirect
              redirect_response_code = path_rule.value.url_redirect.redirect_response_code
              strip_query            = path_rule.value.url_redirect.strip_query
            }
          }

          dynamic "route_action" {
            for_each = try(path_rule.value.route_action, null) == null ? [] : [1]

            content {
              dynamic "cors_policy" {
                # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation 
                # for Cross Origin Resource Sharing
                for_each = try(path_rule.value.route_action.cors_policy, null) == null ? [] : [1]

                content {
                  allow_credentials    = path_rule.value.route_action.cors_policy.allow_credentials
                  allow_headers        = path_rule.value.route_action.cors_policy.allow_headers
                  allow_methods        = path_rule.value.route_action.cors_policy.allow_methods
                  allow_origin_regexes = path_rule.value.route_action.cors_policy.allow_origin_regexes
                  allow_origins        = path_rule.value.route_action.cors_policy.allow_origins
                  disabled             = path_rule.value.route_action.cors_policy.disabled
                  expose_headers       = path_rule.value.route_action.cors_policy.expose_headers
                  max_age              = path_rule.value.route_action.cors_policy.max_age
                }
              }

              dynamic "fault_injection_policy" {
                # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients 
                # to backend service failure. As part of fault injection, when clients send requests to a backend service, 
                # delays can be introduced by Loadbalancer on a percentage of requests before sending those request to 
                # the backend service. Similarly requests from clients can be aborted by the Loadbalancer for a 
                # percentage of requests. timeout and retry_policy will be ignored by clients that are configured 
                # with a fault_injection_policy.
                for_each = try(path_rule.value.route_action.fault_injection_policy, null) == null ? [] : [1]

                content {
                  dynamic "abort" {
                    # (Optional) The specification for how client requests are aborted as part of fault injection.
                    for_each = try(path_rule.value.route_action.fault_injection_policy.abort, null) == null ? [] : [1]

                    content {
                      http_status = path_rule.value.route_action.fault_injection_policy.abort.http_status
                      percentage  = path_rule.value.route_action.fault_injection_policy.abort.percentage
                    }
                  }

                  dynamic "delay" {
                    # (Optional) The specification for how client requests are delayed as part of fault injection, 
                    # before being sent to a backend service.
                    for_each = try(path_rule.value.route_action.fault_injection_policy.delay, null) == null ? [] : [1]

                    content {
                      percentage = path_rule.value.route_action.fault_injection_policy.delay.percentage

                      dynamic "fixed_delay" {
                        # (Optional) Specifies the value of the fixed delay interval
                        for_each = try(path_rule.value.route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                        content {
                          seconds = path_rule.value.route_action.fault_injection_policy.delay.fixed_delay.seconds
                          nanos   = path_rule.value.route_action.fault_injection_policy.delay.fixed_delay.nanos
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "test" {
    # (Optional) The list of expected URL mappings. Requests to update this UrlMap will succeed only if all of the test cases pass.
    for_each = try(each.value.test, null) == null ? [] : [1]

    content {
      description = each.value.test.description
      host        = each.value.test.host
      path        = each.value.test.path
      service     = each.value.test.service
    }
  }

  dynamic "default_url_redirect" {
    # (Optional) When none of the specified hostRules match, the request is redirected to a URL specified by defaultUrlRedirect. If
    #  defaultUrlRedirect is specified, defaultService or defaultRouteAction must not be set.
    for_each = try(each.value.default_url_redirect, null) == null ? [] : [1]

    content {
      host_redirect          = each.value.default_url_redirect.host_redirect
      https_redirect         = each.value.default_url_redirect.https_redirect
      path_redirect          = each.value.default_url_redirect.path_redirect
      prefix_redirect        = each.value.default_url_redirect.prefix_redirect
      redirect_response_code = each.value.default_url_redirect.redirect_response_code
      strip_query            = each.value.default_url_redirect.strip_query
    }
  }

  dynamic "default_route_action" {
    # (Optional) defaultRouteAction takes effect when none of the hostRules match. The load balancer performs advanced routing actions,
    # such as URL rewrites and header transformations, before forwarding the request to the selected backend. If defaultRouteAction 
    # specifies any weightedBackendServices, defaultService must not be set. Conversely if defaultService is set, defaultRouteAction 
    # cannot contain any weightedBackendServices. Only one of defaultRouteAction or defaultUrlRedirect must be set. URL maps for 
    # Classic external HTTP(S) load balancers only support the urlRewrite action within defaultRouteAction. defaultRouteAction has 
    # no effect when the URL map is bound to a target gRPC proxy that has the validateForProxyless field set to true.
    for_each = try(each.value.default_route_action, null) == null ? [] : [1]

    content {
      dynamic "weighted_backend_services" {
        # (Optional) A list of weighted backend services to send traffic to when a route match occurs. The weights determine the 
        # fraction of traffic that flows to their corresponding backend service. If all traffic needs to go to a single backend 
        # service, there must be one weightedBackendService with weight set to a non-zero number. After a backend service is 
        # identified and before forwarding the request to the backend service, advanced routing actions such as URL rewrites 
        # and header transformations are applied depending on additional settings specified in this HttpRouteAction.
        for_each = try(each.value.default_route_action.weighted_backend_services, null) == null ? [] : [1]

        content {
          backend_service = each.value.default_route_action.weighted_backend_services.backend_service
          weight          = each.value.default_route_action.weighted_backend_services.weight

          dynamic "header_action" {
            # (Optional) Specifies changes to request and response headers that need to take effect for the selected backendService. 
            # headerAction specified here take effect before headerAction in the enclosing HttpRouteRule, PathMatcher and UrlMap.
            # headerAction is not supported for load balancers that have their loadBalancingScheme set to EXTERNAL. Not supported
            #  when the URL map is bound to a target gRPC proxy that has validateForProxyless field set to true. 
            for_each = try(each.value.default_route_action.weighted_backend_services.header_action, null) == null ? [] : [1]

            content {
              request_headers_to_remove  = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_remove
              response_headers_to_remove = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_remove

              dynamic "request_headers_to_add" {
                # (Optional) Headers to add to a matching request prior to forwarding the request to the backendService. 
                for_each = try(each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.header_name
                  header_value = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.header_value
                  replace      = each.value.default_route_action.weighted_backend_services.header_action.request_headers_to_add.replace
                }
              }

              dynamic "response_headers_to_add" {
                # (Optional) Headers to add the response prior to sending the response back to the client.
                for_each = try(each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add, null) == null ? [] : [1]

                content {
                  header_name  = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.header_name
                  header_value = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.header_value
                  replace      = each.value.default_route_action.weighted_backend_services.header_action.response_headers_to_add.replace
                }
              }
            }
          }
        }
      }

      dynamic "url_rewrite" {
        # (Optional) The spec to modify the URL of the request, before forwarding the request to the matched service. urlRewrite is the 
        # only action supported in UrlMaps for external HTTP(S) load balancers. Not supported when the URL map is bound to a target
        # gRPC proxy that has the validateForProxyless field set to true.
        for_each = try(each.value.default_route_action.url_rewrite, null) == null ? [] : [1]

        content {
          path_prefix_rewrite = each.value.default_route_action.url_rewrite.path_prefix_rewrite
          host_rewrite        = each.value.default_route_action.url_rewrite.host_rewrite
        }
      }

      dynamic "timeout" {
        # (Optional) Specifies the timeout for the selected route. Timeout is computed from the time the request has been fully processed 
        # (known as end-of-stream) up until the response has been processed. Timeout includes all retries. If not specified, this field
        #  uses the largest timeout among all backend services associated with the route. Not supported when the URL map is bound to a
        #  target gRPC proxy that has validateForProxyless field set to true.
        for_each = try(each.value.default_route_action.timeout, null) == null ? [] : [1]

        content {
          seconds = each.value.default_route_action.timeout.seconds
          nanos   = each.value.default_route_action.timeout.nanos
        }
      }

      dynamic "retry_policy" {
        # (Optional) Specifies the retry policy associated with this route.
        for_each = try(each.value.default_route_action.retry_policy, null) == null ? [] : [1]

        content {
          retry_conditions = each.value.default_route_action.retry_policy.retry_conditions
          num_retries      = each.value.default_route_action.retry_policy.num_retries

          dynamic "per_try_timeout" {
            # (Optional) Specifies a non-zero timeout per retry attempt. If not specified, will use the timeout set in HttpRouteAction.
            # If timeout in HttpRouteAction is not set, will use the largest timeout among all backend services associated with the route.
            for_each = try(each.value.default_route_action.per_try_timeout, null) == null ? [] : [1]

            content {
              seconds = each.value.default_route_action.per_try_timeout.seconds
              nanos   = each.value.default_route_action.per_try_timeout.nanos
            }
          }
        }
      }

      dynamic "request_mirror_policy" {
        # (Optional) Specifies the policy on how requests intended for the route's backends are shadowed to a separate mirrored backend 
        # service. The load balancer does not wait for responses from the shadow service. Before sending traffic to the shadow service,
        # the host / authority header is suffixed with -shadow. Not supported when the URL map is bound to a target gRPC proxy that
        # has the validateForProxyless field set to true.
        for_each = try(each.value.default_route_actionrequest_mirror_policy, null) == null ? [] : [1]

        content {
          backend_service = each.value.default_route_actionrequest_mirror_policy.backend_service
        }
      }

      dynamic "cors_policy" {
        # (Optional) The specification for allowing client side cross-origin requests. Please see W3C Recommendation for Cross Origin Resource Sharing
        for_each = try(each.value.default_route_action.cors_policy, null) == null ? [] : [1]

        content {
          allow_origins        = each.value.default_route_action.cors_policy.allow_origins
          allow_origin_regexes = each.value.default_route_action.cors_policy.allow_origin_regexes
          allow_methods        = each.value.default_route_action.cors_policy.allow_methods
          allow_headers        = each.value.default_route_action.cors_policy.allow_headers
          expose_headers       = each.value.default_route_action.cors_policy.expose_headers
          max_age              = each.value.default_route_action.cors_policy.max_age
          allow_credentials    = each.value.default_route_action.cors_policy.allow_credentials
          disabled             = each.value.default_route_action.cors_policy.disabled

        }
      }

      dynamic "fault_injection_policy" {
        # (Optional) The specification for fault injection introduced into traffic to test the resiliency of clients to backend service failure. As part of fault injection, when clients send requests to a backend service, delays can be introduced by a load balancer on a percentage of requests before sending those requests to the backend service. Similarly requests from clients can be aborted by the load balancer for a percentage of requests. timeout and retryPolicy is ignored by clients that are configured with a faultInjectionPolicy if: 1. The traffic is generated by fault injection AND 2. The fault injection is not a delay fault injection. Fault injection is not supported with the global external HTTP(S) load balancer (classic). To see which load balancers support fault injection, see Load balancing: Routing and traffic management features.
        for_each = try(each.value.default_route_action.fault_injection_policy, null) == null ? [] : [1]

        content {
          dynamic "abort" {
            # (Optional) The specification for how client requests are aborted as part of fault injection.
            for_each = try(each.value.default_route_action.fault_injection_policy.abort, null) == null ? [] : [1]

            content {
              http_status = each.value.default_route_action.fault_injection_policy.abort.http_status
              percentage  = each.value.default_route_action.fault_injection_policy.abort.percentage
            }
          }

          dynamic "delay" {
            # (Optional) The specification for how client requests are delayed as part of fault injection, 
            # before being sent to a backend service.
            for_each = try(each.value.default_route_action.fault_injection_policy.delay, null) == null ? [] : [1]

            content {
              percentage = each.value.default_route_action.fault_injection_policy.delay.percentage

              dynamic "fixed_delay" {
                # (Optional) Specifies the value of the fixed delay interval
                for_each = try(each.value.default_route_action.fault_injection_policy.delay.fixed_delay, null) == null ? [] : [1]

                content {
                  seconds = each.value.default_route_action.fault_injection_policy.delay.fixed_delay.seconds
                  nanos   = each.value.default_route_action.fault_injection_policy.delay.fixed_delay.nanos
                }
              }
            }
          }

        }
      }
    }
  }
}

locals {
  #
  # A variable with all the URL Maps for easy lookup
  #
  google_compute_url_map = merge(
    google_compute_region_url_map.lz,
    google_compute_url_map.lz,
  )
}
