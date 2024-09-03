#
# Instance Groups
#

resource "google_compute_instance_group" "lz" {
  #
  # GCP Compute Instance Groups
  #
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group
  for_each = {
    for group in local.gcp_compute_instance_group : group.resource_index => group
  }

  name    = each.value.name
  zone    = each.value.zone
  project = each.value.project

  description = each.value.description
  instances = each.value.instances == null ? null : [
    for instance in each.value.instances : lookup(local.google_compute_instance, instance, null) == null ? instance : local.google_compute_instance[instance].self_link
  ]
  network = each.value.network

  dynamic "named_port" {
    for_each = coalesce(each.value.named_port, [])

    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}

#
# Managed Instance Groups
#

resource "google_compute_region_health_check" "lz" {
  #
  # GCP Compute Instance Health Check (Regional)
  #
  for_each = {
    for health_check in local.gcp_compute_health_check : health_check.resource_index => health_check
    if health_check.region != null
  }

  name                = each.value.name
  check_interval_sec  = each.value.check_interval_sec
  description         = each.value.description
  healthy_threshold   = each.value.healthy_threshold
  timeout_sec         = each.value.timeout_sec
  unhealthy_threshold = each.value.unhealthy_threshold
  project             = each.value.project
  region              = each.value.region

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

  dynamic "http2_health_check" {
    for_each = try(each.value.http2_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.http2_health_check.host
      request_path       = each.value.http2_health_check.request_path
      response           = each.value.http2_health_check.response
      port               = each.value.http2_health_check.port
      port_name          = each.value.http2_health_check.port_name
      proxy_header       = each.value.http2_health_check.proxy_header
      port_specification = each.value.http2_health_check.port_specification

    }
  }

  dynamic "grpc_health_check" {
    for_each = try(each.value.grpc_health_check, null) == null ? [] : [1]

    content {
      port               = each.value.grpc_health_check.port
      port_name          = each.value.grpc_health_check.port_name
      port_specification = each.value.grpc_health_check.port_specification
      grpc_service_name  = each.value.grpc_health_check.grpc_service_name
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
  # GCP Compute Instance Health Check (Global)
  #
  for_each = {
    for health_check in local.gcp_compute_health_check : health_check.resource_index => health_check
    if health_check.region == null
  }

  name                = each.value.name
  check_interval_sec  = each.value.check_interval_sec
  description         = each.value.description
  healthy_threshold   = each.value.healthy_threshold
  timeout_sec         = each.value.timeout_sec
  unhealthy_threshold = each.value.unhealthy_threshold
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

  dynamic "http2_health_check" {
    for_each = try(each.value.http2_health_check, null) == null ? [] : [1]

    content {
      host               = each.value.http2_health_check.host
      request_path       = each.value.http2_health_check.request_path
      response           = each.value.http2_health_check.response
      port               = each.value.http2_health_check.port
      port_name          = each.value.http2_health_check.port_name
      proxy_header       = each.value.http2_health_check.proxy_header
      port_specification = each.value.http2_health_check.port_specification

    }
  }

  dynamic "grpc_health_check" {
    for_each = try(each.value.grpc_health_check, null) == null ? [] : [1]

    content {
      port               = each.value.grpc_health_check.port
      port_name          = each.value.grpc_health_check.port_name
      port_specification = each.value.grpc_health_check.port_specification
      grpc_service_name  = each.value.grpc_health_check.grpc_service_name
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

resource "google_compute_region_instance_group_manager" "lz" {
  #
  # GCP Compute Instance Group Manager (Regional)
  #
  for_each = {
    for instance_manager in local.gcp_compute_instance_group_manager : instance_manager.resource_index => instance_manager
    if instance_manager.region != null
  }

  provider = google-beta

  base_instance_name             = each.value.base_instance_name
  name                           = each.value.name
  region                         = each.value.region
  description                    = each.value.description
  project                        = each.value.project
  target_size                    = each.value.target_size
  list_managed_instances_results = each.value.list_managed_instances_results
  target_pools                   = each.value.target_pools
  wait_for_instances             = each.value.wait_for_instances
  wait_for_instances_status      = each.value.wait_for_instances_status

  dynamic "version" {
    # (Required) Application versions managed by this instance group. Each version deals with a specific instance template, 
    # allowing canary release scenarios.
    for_each = coalesce(each.value.version, [])

    content {
      name              = version.value.name
      instance_template = try(google_compute_instance_template.lz[version.value.instance_template].self_link, try(google_compute_region_instance_template.lz[version.value.instance_template].self_link, version.value.instance_template))

      dynamic "target_size" {
        for_each = try(version.value.target_size, null) == null ? [] : [1]

        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  dynamic "update_policy" {
    # (Optional) The update policy for this managed instance group.
    for_each = try(each.value.update_policy, null) == null ? [] : [1]

    content {
      minimal_action                 = each.value.update_policy.minimal_action
      most_disruptive_allowed_action = each.value.update_policy.most_disruptive_allowed_action
      type                           = each.value.update_policy.type
      max_surge_fixed                = each.value.update_policy.max_surge_fixed
      max_surge_percent              = each.value.update_policy.max_surge_percent
      max_unavailable_fixed          = each.value.update_policy.max_unavailable_fixed
      max_unavailable_percent        = each.value.update_policy.max_unavailable_percent
      min_ready_sec                  = each.value.update_policy.min_ready_sec
      replacement_method             = each.value.update_policy.replacement_method
    }
  }

  dynamic "all_instances_config" {
    # (Optional, Beta) Properties to set on all instances in the group. After setting allInstancesConfig on the group, you must
    # update the group's instances to apply the configuration.
    for_each = try(each.value.all_instances_config, null) == null ? [] : [1]

    content {
      metadata = each.value.all_instances_config.metadata
      labels   = each.value.all_instances_config.labels
    }
  }

  dynamic "named_port" {
    # (Optional) The named port configuration.
    for_each = coalesce(each.value.named_port, [])

    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  dynamic "auto_healing_policies" {
    #  (Optional) The autohealing policies for this managed instance group. You can specify only one value.
    for_each = try(each.value.auto_healing_policies, null) == null ? [] : [1]

    content {
      health_check      = each.value.auto_healing_policies.health_check
      initial_delay_sec = each.value.auto_healing_policies.initial_delay_sec
    }
  }

  dynamic "stateful_disk" {
    # (Optional) Disks created on the instances that will be preserved on instance delete, update, etc.
    for_each = coalesce(each.value.stateful_disk, [])

    content {
      device_name = stateful_disk.value.device_name
      delete_rule = stateful_disk.value.delete_rule
    }
  }

  dynamic "stateful_internal_ip" {
    # (Optional) Internal network IPs assigned to the instances that will be preserved on instance delete, update, etc. This map 
    # is keyed with the network interface name. 
    for_each = coalesce(each.value.stateful_internal_ip, [])

    content {
      interface_name = stateful_internal_ip.value.interface_name
      delete_rule    = stateful_internal_ip.value.delete_rule
    }
  }

  dynamic "stateful_external_ip" {
    # (Optional) External network IPs assigned to the instances that will be preserved on instance delete, update, etc. This map 
    # is keyed with the network interface name. 
    for_each = coalesce(each.value.stateful_external_ip, [])

    content {
      interface_name = stateful_external_ip.value.interface_name
      delete_rule    = stateful_external_ip.value.delete_rule
    }
  }

  depends_on = [
    google_compute_instance_template.lz,
    google_compute_region_instance_template.lz,
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_instance_group_manager" "lz" {
  #
  # GCP Compute Instance Group Manager (Global)
  #
  for_each = {
    for instance_manager in local.gcp_compute_instance_group_manager : instance_manager.resource_index => instance_manager
    if instance_manager.zone != null
  }

  provider = google-beta

  base_instance_name             = each.value.base_instance_name
  name                           = each.value.name
  zone                           = each.value.zone
  description                    = each.value.description
  project                        = each.value.project
  target_size                    = each.value.target_size
  list_managed_instances_results = each.value.list_managed_instances_results
  target_pools                   = each.value.target_pools
  wait_for_instances             = each.value.wait_for_instances
  wait_for_instances_status      = each.value.wait_for_instances_status

  dynamic "version" {
    # (Required) Application versions managed by this instance group. Each version deals with a specific instance template, 
    # allowing canary release scenarios.
    for_each = coalesce(each.value.version, [])

    content {
      name              = version.value.name
      instance_template = try(google_compute_instance_template.lz[version.value.instance_template].self_link, try(google_compute_region_instance_template.lz[version.value.instance_template].self_link, version.value.instance_template))

      dynamic "target_size" {
        for_each = try(version.value.target_size, null) == null ? [] : [1]

        content {
          fixed   = version.value.target_size.fixed
          percent = version.value.target_size.percent
        }
      }
    }
  }

  dynamic "update_policy" {
    # (Optional) The update policy for this managed instance group.
    for_each = try(each.value.update_policy, null) == null ? [] : [1]

    content {
      minimal_action                 = each.value.update_policy.minimal_action
      most_disruptive_allowed_action = each.value.update_policy.most_disruptive_allowed_action
      type                           = each.value.update_policy.type
      max_surge_fixed                = each.value.update_policy.max_surge_fixed
      max_surge_percent              = each.value.update_policy.max_surge_percent
      max_unavailable_fixed          = each.value.update_policy.max_unavailable_fixed
      max_unavailable_percent        = each.value.update_policy.max_unavailable_percent
      min_ready_sec                  = each.value.update_policy.min_ready_sec
      replacement_method             = each.value.update_policy.replacement_method
    }
  }

  dynamic "all_instances_config" {
    # (Optional, Beta) Properties to set on all instances in the group. After setting allInstancesConfig on the group, you must
    # update the group's instances to apply the configuration.
    for_each = try(each.value.all_instances_config, null) == null ? [] : [1]

    content {
      metadata = each.value.all_instances_config.metadata
      labels   = each.value.all_instances_config.labels
    }
  }

  dynamic "named_port" {
    # (Optional) The named port configuration.
    for_each = coalesce(each.value.named_port, [])

    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }

  dynamic "auto_healing_policies" {
    #  (Optional) The autohealing policies for this managed instance group. You can specify only one value.
    for_each = try(each.value.auto_healing_policies, null) == null ? [] : [1]

    content {
      health_check      = each.value.auto_healing_policies.health_check
      initial_delay_sec = each.value.auto_healing_policies.initial_delay_sec
    }
  }

  dynamic "stateful_disk" {
    # (Optional) Disks created on the instances that will be preserved on instance delete, update, etc.
    for_each = coalesce(each.value.stateful_disk, [])

    content {
      device_name = stateful_disk.value.device_name
      delete_rule = stateful_disk.value.delete_rule
    }
  }

  dynamic "stateful_internal_ip" {
    # (Optional) Internal network IPs assigned to the instances that will be preserved on instance delete, update, etc. This map 
    # is keyed with the network interface name. 
    for_each = coalesce(each.value.stateful_internal_ip, [])

    content {
      interface_name = stateful_internal_ip.value.interface_name
      delete_rule    = stateful_internal_ip.value.delete_rule
    }
  }

  dynamic "stateful_external_ip" {
    # (Optional) External network IPs assigned to the instances that will be preserved on instance delete, update, etc. This map 
    # is keyed with the network interface name. 
    for_each = coalesce(each.value.stateful_external_ip, [])

    content {
      interface_name = stateful_external_ip.value.interface_name
      delete_rule    = stateful_external_ip.value.delete_rule
    }
  }

  depends_on = [
    google_compute_instance_template.lz,
    google_compute_region_instance_template.lz,
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_autoscaler" "lz" {
  #
  # GCP Compute Instance Autoscaler (Global)
  #
  for_each = {
    for autoscaler in local.gcp_compute_autoscaler : autoscaler.resource_index => autoscaler
    if autoscaler.zone != null
  }

  provider = google-beta

  name        = each.value.name
  description = each.value.description
  zone        = each.value.zone
  project     = each.value.project
  target      = each.value.target

  dynamic "autoscaling_policy" {
    # (Required) The configuration parameters for the autoscaling algorithm. You can define one or more of the policies for an
    # autoscaler: cpuUtilization, customMetricUtilizations, and loadBalancingUtilization. If none of these are specified, the 
    # default will be to autoscale based on cpuUtilization to 0.6 or 60%. 
    for_each = coalesce(each.value.autoscaling_policy, [])

    content {
      min_replicas    = autoscaling_policy.value.min_replicas
      max_replicas    = autoscaling_policy.value.max_replicas
      cooldown_period = autoscaling_policy.value.cooldown_period
      mode            = autoscaling_policy.value.mode

      dynamic "scale_down_control" {
        # (Optional, Beta) Defines scale down controls to reduce the risk of response latency and outages due to abrupt 
        # scale-in events
        for_each = try(autoscaling_policy.value.scale_down_control, null) == null ? [] : [1]

        content {
          time_window_sec = autoscaling_policy.value.scale_down_control.time_window_sec

          dynamic "max_scaled_down_replicas" {
            # (Optional) A nested object resource 
            for_each = try(autoscaling_policy.value.scale_down_control.max_scaled_down_replicas, null) == null ? [] : [1]

            content {
              fixed   = autoscaling_policy.value.scale_down_control.max_scaled_down_replicas.fixed
              percent = autoscaling_policy.value.scale_down_control.max_scaled_down_replicas.percent
            }
          }
        }
      }

      dynamic "scale_in_control" {
        # (Optional) Defines scale in controls to reduce the risk of response latency and outages due to abrupt scale-in events
        for_each = try(autoscaling_policy.value.scale_in_control, null) == null ? [] : [1]

        content {
          time_window_sec = autoscaling_policy.value.scale_in_control.time_window_sec

          dynamic "max_scaled_in_replicas" {
            # (Optional) A nested object resource
            for_each = try(autoscaling_policy.value.scale_in_control.max_scaled_in_replicas, null) == null ? [] : [1]

            content {
              fixed   = autoscaling_policy.value.scale_in_control.max_scaled_in_replicas.fixed
              percent = autoscaling_policy.value.scale_in_control.max_scaled_in_replicas.percent
            }
          }
        }
      }

      dynamic "cpu_utilization" {
        # (Optional) Defines the CPU utilization policy that allows the autoscaler to scale based on the average CPU utilization
        # of a managed instance group.
        for_each = try(autoscaling_policy.value.cpu_utilization, null) == null ? [] : [1]

        content {
          target            = autoscaling_policy.value.cpu_utilization.target
          predictive_method = autoscaling_policy.value.cpu_utilization.predictive_method
        }
      }

      dynamic "metric" {
        # (Optional) Configuration parameters of autoscaling based on a custom metric.
        for_each = try(autoscaling_policy.value.metric, null) == null ? [] : [1]

        content {
          name   = autoscaling_policy.value.metric.name
          target = autoscaling_policy.value.metric.target
          type   = autoscaling_policy.value.metric.type
          # single_instance_assignment = autoscaling_policy.value.metric.single_instance_assignment
          # filter                     = autoscaling_policy.value.metric.filter
        }
      }

      dynamic "load_balancing_utilization" {
        # (Optional) Configuration parameters of autoscaling based on a load balancer. 
        for_each = try(autoscaling_policy.value.load_balancing_utilization, null) == null ? [] : [1]

        content {
          target = autoscaling_policy.value.load_balancing_utilization.target
        }
      }

      dynamic "scaling_schedules" {
        # (Optional) Scaling schedules defined for an autoscaler. Multiple schedules can be set on an autoscaler and they 
        # can overlap. 
        for_each = try(autoscaling_policy.value.scaling_schedules, null) == null ? [] : [1]

        content {
          name                  = autoscaling_policy.value.scaling_schedules.name
          min_required_replicas = autoscaling_policy.value.scaling_schedules.min_required_replicas
          schedule              = autoscaling_policy.value.scaling_schedules.schedule
          time_zone             = autoscaling_policy.value.scaling_schedules.time_zone
          duration_sec          = autoscaling_policy.value.scaling_schedules.duration_sec
          disabled              = autoscaling_policy.value.scaling_schedules.disabled
          description           = autoscaling_policy.value.scaling_schedules.description
        }
      }
    }
  }
}

resource "google_compute_region_autoscaler" "lz" {
  #
  # GCP Compute Instance Autoscaler (Regional)
  #
  for_each = {
    for autoscaler in local.gcp_compute_autoscaler : autoscaler.resource_index => autoscaler
    if autoscaler.region != null
  }

  provider = google-beta

  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  project     = each.value.project
  target      = each.value.target

  dynamic "autoscaling_policy" {
    # (Required) The configuration parameters for the autoscaling algorithm. You can define one or more of the policies for an
    # autoscaler: cpuUtilization, customMetricUtilizations, and loadBalancingUtilization. If none of these are specified, the 
    # default will be to autoscale based on cpuUtilization to 0.6 or 60%. 
    for_each = coalesce(each.value.autoscaling_policy, [])

    content {
      min_replicas    = autoscaling_policy.value.min_replicas
      max_replicas    = autoscaling_policy.value.max_replicas
      cooldown_period = autoscaling_policy.value.cooldown_period
      mode            = autoscaling_policy.value.mode

      dynamic "scale_down_control" {
        # (Optional, Beta) Defines scale down controls to reduce the risk of response latency and outages due to abrupt 
        # scale-in events
        for_each = try(autoscaling_policy.value.scale_down_control, null) == null ? [] : [1]

        content {
          time_window_sec = autoscaling_policy.value.scale_down_control.time_window_sec

          dynamic "max_scaled_down_replicas" {
            # (Optional) A nested object resource 
            for_each = try(autoscaling_policy.value.scale_down_control.max_scaled_down_replicas, null) == null ? [] : [1]

            content {
              fixed   = autoscaling_policy.value.scale_down_control.max_scaled_down_replicas.fixed
              percent = autoscaling_policy.value.scale_down_control.max_scaled_down_replicas.percent
            }
          }
        }
      }

      dynamic "scale_in_control" {
        # (Optional) Defines scale in controls to reduce the risk of response latency and outages due to abrupt scale-in events
        for_each = try(autoscaling_policy.value.scale_in_control, null) == null ? [] : [1]

        content {
          time_window_sec = autoscaling_policy.value.scale_in_control.time_window_sec

          dynamic "max_scaled_in_replicas" {
            # (Optional) A nested object resource
            for_each = try(autoscaling_policy.value.scale_in_control.max_scaled_in_replicas, null) == null ? [] : [1]

            content {
              fixed   = autoscaling_policy.value.scale_in_control.max_scaled_in_replicas.fixed
              percent = autoscaling_policy.value.scale_in_control.max_scaled_in_replicas.percent
            }
          }
        }
      }

      dynamic "cpu_utilization" {
        # (Optional) Defines the CPU utilization policy that allows the autoscaler to scale based on the average CPU utilization
        # of a managed instance group.
        for_each = try(autoscaling_policy.value.cpu_utilization, null) == null ? [] : [1]

        content {
          target            = autoscaling_policy.value.cpu_utilization.target
          predictive_method = autoscaling_policy.value.cpu_utilization.predictive_method
        }
      }

      dynamic "metric" {
        # (Optional) Configuration parameters of autoscaling based on a custom metric.
        for_each = try(autoscaling_policy.value.metric, null) == null ? [] : [1]

        content {
          name   = autoscaling_policy.value.metric.name
          target = autoscaling_policy.value.metric.target
          type   = autoscaling_policy.value.metric.type
          # single_instance_assignment = autoscaling_policy.value.metric.single_instance_assignment
          # filter                     = autoscaling_policy.value.metric.filter
        }
      }

      dynamic "load_balancing_utilization" {
        # (Optional) Configuration parameters of autoscaling based on a load balancer. 
        for_each = try(autoscaling_policy.value.load_balancing_utilization, null) == null ? [] : [1]

        content {
          target = autoscaling_policy.value.load_balancing_utilization.target
        }
      }

      dynamic "scaling_schedules" {
        # (Optional) Scaling schedules defined for an autoscaler. Multiple schedules can be set on an autoscaler and they 
        # can overlap. 
        for_each = try(autoscaling_policy.value.scaling_schedules, null) == null ? [] : [1]

        content {
          name                  = autoscaling_policy.value.scaling_schedules.name
          min_required_replicas = autoscaling_policy.value.scaling_schedules.min_required_replicas
          schedule              = autoscaling_policy.value.scaling_schedules.schedule
          time_zone             = autoscaling_policy.value.scaling_schedules.time_zone
          duration_sec          = autoscaling_policy.value.scaling_schedules.duration_sec
          disabled              = autoscaling_policy.value.scaling_schedules.disabled
          description           = autoscaling_policy.value.scaling_schedules.description
        }
      }
    }
  }
}

data "cloudinit_config" "instance_group" {
  #
  # Cloud Init configurations for instance group templates
  #
  for_each = {
    for instance_template in local.gcp_compute_instance_template : instance_template.resource_index => instance_template
    if instance_template.cloudinit_config_file != null
  }

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file(each.value.cloudinit_config_file)
    filename     = "cloudinit_config.yaml"
  }
}

resource "google_compute_instance_template" "lz" {
  #
  # GCP Compute Instance Templates (Global)
  #
  for_each = {
    for instance_template in local.gcp_compute_instance_template : instance_template.resource_index => instance_template
    if instance_template.regional != true
  }

  lifecycle {
    #
    # Instance templates are immutable
    #
    create_before_destroy = true
  }

  project = each.value.project
  region  = each.value.region

  name        = each.value.name
  name_prefix = each.value.name_prefix
  description = each.value.description
  labels      = each.value.labels
  metadata = merge(
    try(each.value.metadata, null),
    each.value.cloudinit_config_file == null ? null : {
      user-data = data.cloudinit_config.instance_group[each.key].rendered
    }
  )
  metadata_startup_script = each.value.metadata_startup_script == null ? null : fileexists(each.value.metadata_startup_script) ? file(each.value.metadata_startup_script) : each.value.metadata_startup_script

  machine_type         = each.value.machine_type
  can_ip_forward       = each.value.can_ip_forward
  instance_description = each.value.instance_description
  resource_policies    = each.value.resource_policies
  tags                 = each.value.tags
  min_cpu_platform     = each.value.min_cpu_platform
  # enable_display          = each.value.enable_display

  dynamic "guest_accelerator" {
    # (Optional) List of the type and count of accelerator cards attached to the instance.
    for_each = try(each.value.guest_accelerator, null) == null ? [] : [1]

    content {
      type  = each.value.guest_accelerator.type
      count = each.value.guest_accelerator.count

      /*
      dynamic "local_ssd_recovery_timeout" {
        # (Optional) List of the type and count of accelerator cards attached to the instance. 
        for_each = try(each.value.guest_accelerator.local_ssd_recovery_timeout, null) == null ? [] : [1]

        content {
          nanos   = each.value.guest_accelerator.local_ssd_recovery_timeout.nanos
          seconds = each.value.guest_accelerator.local_ssd_recovery_timeout.seconds
        }
      }
      */
    }
  }

  dynamic "shielded_instance_config" {
    # (Optional) Enable Shielded VM on this instance. Shielded VM provides verifiable integrity to prevent against malware and rootkits. Defaults to disabled. Structure is documented below. Note: shielded_instance_config can only be used with boot images with shielded vm support. See the complete list here. Note: allow_stopping_for_update must be set to true or your instance must have a desired_status of TERMINATED in order to update this field.
    for_each = try(each.value.shielded_instance_config, null) == null ? [] : [1]

    content {
      enable_secure_boot          = try(each.value.shielded_instance_config.enable_secure_boot, null)
      enable_vtpm                 = try(each.value.shielded_instance_config.enable_vtpm, null)
      enable_integrity_monitoring = try(each.value.shielded_instance_config.enable_integrity_monitoring, null)
    }
  }

  dynamic "confidential_instance_config" {
    # (Optional) - Enable Confidential Mode on this VM.
    for_each = try(each.value.confidential_instance_config, null) == null ? [] : [1]

    content {
      enable_confidential_compute = try(each.value.confidential_instance_config.enable_confidential_compute, null)
    }
  }

  dynamic "advanced_machine_features" {
    # (Optional) - Configure Nested Virtualisation and Simultaneous Hyper Threading on this VM.
    for_each = try(each.value.advanced_machine_features, null) == null ? [] : [1]

    content {
      enable_nested_virtualization = try(each.value.advanced_machine_features.enable_nested_virtualization, null)
      threads_per_core             = try(each.value.advanced_machine_features.threads_per_core, null)
      visible_core_count           = try(each.value.advanced_machine_features.visible_core_count, null)
    }
  }

  dynamic "reservation_affinity" {
    # (Optional) Specifies the reservations that this instance can consume from. 
    for_each = try(each.value.reservation_affinity, null) == null ? [] : [1]

    content {
      type = try(each.value.reservation_affinity.type, null)

      dynamic "specific_reservation" {
        # (Optional, Beta Configures network performance settings for the instance. 
        for_each = try(each.value.reservation_affinity.specific_reservation, null) == null ? [] : [1]

        content {
          key    = each.value.reservation_affinity.specific_reservation.key
          values = each.value.reservation_affinity.specific_reservation.values
        }
      }
    }
  }

  dynamic "network_performance_config" {
    # (Optional, Beta Configures network performance settings for the instance. 
    for_each = try(each.value.network_performance_config, null) == null ? [] : [1]

    content {
      total_egress_bandwidth_tier = try(each.value.network_performance_config.total_egress_bandwidth_tier, null)
    }
  }

  dynamic "service_account" {
    # (Optional) Service account to attach to the instance. Structure is documented below. Note: allow_stopping_for_update must be set to true or your instance must have a desired_status of TERMINATED in order to update this field.
    for_each = try(each.value.service_account, null) == null ? [] : [1]

    content {
      email  = try(each.value.service_account.email, null) == null ? null : lookup(local.compute_service_account, each.value.service_account.email, null) == null ? each.value.service_account.email : google_service_account.compute[each.value.service_account.email].email
      scopes = each.value.service_account.scopes
    }
  }

  dynamic "scheduling" {
    # (Optional) The scheduling strategy to use. 
    for_each = try(each.value.scheduling, null) == null ? [] : [1]

    content {
      preemptible                 = try(each.value.scheduling.preemptible, null)
      on_host_maintenance         = try(each.value.scheduling.on_host_maintenance, null)
      automatic_restart           = try(each.value.scheduling.automatic_restart, null)
      min_node_cpus               = try(each.value.scheduling.min_node_cpus, null)
      provisioning_model          = try(each.value.scheduling.provisioning_model, null)
      instance_termination_action = try(each.value.scheduling.instance_termination_action, null)
      # max_run_duration = try(each.value.scheduling.max_run_duration, null)
      # maintenance_interval = try(each.value.scheduling.maintenance_interval, null)
      /*
       * There's some sort of error in Terraform documentation
       *
      nanos = try(each.value.scheduling.nanos, null)
      seconds = try(each.value.scheduling.seconds, null)
      local_ssd_recovery_timeout = try(each.value.scheduling.local_ssd_recovery_timeout, null)
      seconds = try(each.value.scheduling.seconds, null)
      type = try(each.value.scheduling.type, null)
      count = try(each.value.scheduling.count, null)
      */

      # (Optional) Specifies node affinities or anti-affinities to determine which sole-tenant nodes your instances and managed instance groups will use as host systems.
      dynamic "node_affinities" {
        # (Optional) The scheduling strategy to use. 
        for_each = try(each.value.scheduling.node_affinities, null) == null ? [] : [1]

        content {
          key      = each.value.scheduling.node_affinities.key
          operator = each.value.scheduling.node_affinities.operator
          values   = each.value.scheduling.node_affinities.values
        }
      }
    }
  }

  dynamic "network_interface" {
    # (Required) Networks to attach to the instance. This can be specified multiple times. 
    for_each = coalesce(each.value.network_interface, [])

    content {
      network            = network_interface.value.network
      subnetwork         = network_interface.value.subnetwork
      subnetwork_project = network_interface.value.subnetwork_project
      network_ip         = network_interface.value.network_ip
      stack_type         = network_interface.value.stack_type
      queue_count        = network_interface.value.queue_count
      # network_attachment = network_interface.value.network_attachment
      # security_policy    = network_interface.value.security_policy

      dynamic "access_config" {
        # (Optional) Access configurations, i.e. IPs via which this instance can be accessed via the Internet. 
        # Omit to ensure that the instance is not accessible from the Internet. If omitted, ssh provisioners will 
        # not work unless Terraform can send traffic to the instance's network (e.g. via tunnel or because it is 
        # running on another cloud instance on that network). This block can be repeated multiple times.
        for_each = coalesce(network_interface.value.access_config, [])

        content {
          nat_ip                 = access_config.value.nat_ip
          public_ptr_domain_name = access_config.value.public_ptr_domain_name
          network_tier           = access_config.value.network_tier
        }
      }

      dynamic "ipv6_access_config" {
        # (Optional) An array of IPv6 access configurations for this interface. Currently, only one IPv6 access config, 
        # DIRECT_IPV6, is supported. If there is no ipv6AccessConfig specified, then this instance will have no 
        # external IPv6 Internet access. 
        for_each = coalesce(network_interface.value.ipv6_access_config, [])

        content {
          external_ipv6               = ipv6_access_config.value.external_ipv6
          external_ipv6_prefix_length = ipv6_access_config.value.external_ipv6_prefix_length
          name                        = ipv6_access_config.value.name
          network_tier                = ipv6_access_config.value.network_tier
          public_ptr_domain_name      = ipv6_access_config.value.public_ptr_domain_name
        }
      }

      dynamic "alias_ip_range" {
        # (Optional) An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks. 
        for_each = network_interface.value.alias_ip_range == null ? [] : [1]

        content {
          ip_cidr_range         = network_interface.value.alias_ip_range.ip_cidr_range
          subnetwork_range_name = network_interface.value.alias_ip_range.subnetwork_range_name
        }
      }
    }
  }

  dynamic "disk" {
    # (Required) Disks to attach to instances created from this template. This can be specified multiple times for multiple disks.
    for_each = each.value.disk

    content {
      auto_delete       = disk.value.auto_delete
      boot              = disk.value.boot
      device_name       = disk.value.device_name
      disk_name         = disk.value.disk_name
      provisioned_iops  = disk.value.provisioned_iops
      source_image      = disk.value.source_image
      source_snapshot   = disk.value.source_snapshot
      interface         = disk.value.interface
      mode              = disk.value.mode
      source            = disk.value.source
      disk_type         = disk.value.disk_type
      disk_size_gb      = disk.value.disk_size_gb
      labels            = disk.value.labels
      type              = disk.value.type
      resource_policies = disk.value.resource_policies

      dynamic "source_image_encryption_key" {
        # (Optional) The customer-supplied encryption key of the source image. Required if the source image is protected by a 
        # customer-supplied encryption key.
        #
        # Instance templates do not store customer-supplied encryption keys, so you cannot create disks for instances in a managed 
        # instance group if the source images are encrypted with your own keys. 
        for_each = disk.value.source_image_encryption_key == null ? [] : [1]

        content {
          kms_key_service_account = disk.value.source_image_encryption_key.kms_key_service_account
          kms_key_self_link       = disk.value.source_image_encryption_key.kms_key_self_link
        }
      }

      dynamic "source_snapshot_encryption_key" {
        # (Optional) The customer-supplied encryption key of the source snapshot.
        for_each = disk.value.source_snapshot_encryption_key == null ? [] : [1]

        content {
          kms_key_service_account = disk.value.source_snapshot_encryption_key.kms_key_service_account
          kms_key_self_link       = disk.value.source_snapshot_encryption_key.kms_key_self_link
        }
      }

      dynamic "disk_encryption_key" {
        # (Optional) Encrypts or decrypts a disk using a customer-supplied encryption key.
        #
        # If you are creating a new disk, this field encrypts the new disk using an encryption key that you provide. If you are
        # attaching an existing disk that is already encrypted, this field decrypts the disk using the customer-supplied encryption key.
        #
        # If you encrypt a disk using a customer-supplied key, you must provide the same key again when you attempt to use this 
        # resource at a later time. For example, you must provide the key when you create a snapshot or an image from the disk or 
        # when you attach the disk to a virtual machine instance.
        #
        # If you do not provide an encryption key, then the disk will be encrypted using an automatically generated key and you do 
        # not need to provide a key to use the disk later.
        #
        # Instance templates do not store customer-supplied encryption keys, so you cannot use your own keys to encrypt disks in a 
        # managed instance group. 
        for_each = disk.value.disk_encryption_key == null ? [] : [1]

        content {
          kms_key_self_link = disk.value.disk_encryption_key.kms_key_self_link
        }
      }
    }
  }
}


resource "google_compute_region_instance_template" "lz" {
  #
  # GCP Compute Instance Templates (Regional)
  #
  for_each = {
    for instance_template in local.gcp_compute_instance_template : instance_template.resource_index => instance_template
    if instance_template.regional == true
  }

  lifecycle {
    #
    # Instance templates are immutable
    #
    create_before_destroy = true
  }

  project = each.value.project
  region  = each.value.region

  name        = each.value.name
  name_prefix = each.value.name_prefix
  description = each.value.description
  labels      = each.value.labels
  metadata = merge(
    try(each.value.metadata, null),
    each.value.cloudinit_config_file == null ? null : {
      user-data = data.cloudinit_config.instance_group[each.key].rendered
    }
  )
  metadata_startup_script = each.value.metadata_startup_script == null ? null : fileexists(each.value.metadata_startup_script) ? file(each.value.metadata_startup_script) : each.value.metadata_startup_script

  machine_type         = each.value.machine_type
  can_ip_forward       = each.value.can_ip_forward
  instance_description = each.value.instance_description
  resource_policies    = each.value.resource_policies
  tags                 = each.value.tags
  min_cpu_platform     = each.value.min_cpu_platform
  # enable_display          = each.value.enable_display

  dynamic "guest_accelerator" {
    # (Optional) List of the type and count of accelerator cards attached to the instance.
    for_each = try(each.value.guest_accelerator, null) == null ? [] : [1]

    content {
      type  = each.value.guest_accelerator.type
      count = each.value.guest_accelerator.count

      /*
      dynamic "local_ssd_recovery_timeout" {
        # (Optional) List of the type and count of accelerator cards attached to the instance. 
        for_each = try(each.value.guest_accelerator.local_ssd_recovery_timeout, null) == null ? [] : [1]

        content {
          nanos   = each.value.guest_accelerator.local_ssd_recovery_timeout.nanos
          seconds = each.value.guest_accelerator.local_ssd_recovery_timeout.seconds
        }
      }
      */
    }
  }

  dynamic "shielded_instance_config" {
    # (Optional) Enable Shielded VM on this instance. Shielded VM provides verifiable integrity to prevent against malware and rootkits. Defaults to disabled. Structure is documented below. Note: shielded_instance_config can only be used with boot images with shielded vm support. See the complete list here. Note: allow_stopping_for_update must be set to true or your instance must have a desired_status of TERMINATED in order to update this field.
    for_each = try(each.value.shielded_instance_config, null) == null ? [] : [1]

    content {
      enable_secure_boot          = try(each.value.shielded_instance_config.enable_secure_boot, null)
      enable_vtpm                 = try(each.value.shielded_instance_config.enable_vtpm, null)
      enable_integrity_monitoring = try(each.value.shielded_instance_config.enable_integrity_monitoring, null)
    }
  }

  dynamic "confidential_instance_config" {
    # (Optional) - Enable Confidential Mode on this VM.
    for_each = try(each.value.confidential_instance_config, null) == null ? [] : [1]

    content {
      enable_confidential_compute = try(each.value.confidential_instance_config.enable_confidential_compute, null)
    }
  }

  dynamic "advanced_machine_features" {
    # (Optional) - Configure Nested Virtualisation and Simultaneous Hyper Threading on this VM.
    for_each = try(each.value.advanced_machine_features, null) == null ? [] : [1]

    content {
      enable_nested_virtualization = try(each.value.advanced_machine_features.enable_nested_virtualization, null)
      threads_per_core             = try(each.value.advanced_machine_features.threads_per_core, null)
      visible_core_count           = try(each.value.advanced_machine_features.visible_core_count, null)
    }
  }

  dynamic "reservation_affinity" {
    # (Optional) Specifies the reservations that this instance can consume from. 
    for_each = try(each.value.reservation_affinity, null) == null ? [] : [1]

    content {
      type = try(each.value.reservation_affinity.type, null)

      dynamic "specific_reservation" {
        # (Optional, Beta Configures network performance settings for the instance. 
        for_each = try(each.value.reservation_affinity.specific_reservation, null) == null ? [] : [1]

        content {
          key    = each.value.reservation_affinity.specific_reservation.key
          values = each.value.reservation_affinity.specific_reservation.values
        }
      }
    }
  }

  dynamic "network_performance_config" {
    # (Optional, Beta Configures network performance settings for the instance. 
    for_each = try(each.value.network_performance_config, null) == null ? [] : [1]

    content {
      total_egress_bandwidth_tier = try(each.value.network_performance_config.total_egress_bandwidth_tier, null)
    }
  }

  dynamic "service_account" {
    # (Optional) Service account to attach to the instance. Structure is documented below. Note: allow_stopping_for_update must be set to true or your instance must have a desired_status of TERMINATED in order to update this field.
    for_each = try(each.value.service_account, null) == null ? [] : [1]

    content {
      email  = try(each.value.service_account.email, null) == null ? null : lookup(local.compute_service_account, each.value.service_account.email, null) == null ? each.value.service_account.email : google_service_account.compute[each.value.service_account.email].email
      scopes = each.value.service_account.scopes
    }
  }

  dynamic "scheduling" {
    # (Optional) The scheduling strategy to use. 
    for_each = try(each.value.scheduling, null) == null ? [] : [1]

    content {
      preemptible                 = try(each.value.scheduling.preemptible, null)
      on_host_maintenance         = try(each.value.scheduling.on_host_maintenance, null)
      automatic_restart           = try(each.value.scheduling.automatic_restart, null)
      min_node_cpus               = try(each.value.scheduling.min_node_cpus, null)
      provisioning_model          = try(each.value.scheduling.provisioning_model, null)
      instance_termination_action = try(each.value.scheduling.instance_termination_action, null)
      # max_run_duration = try(each.value.scheduling.max_run_duration, null)
      # maintenance_interval = try(each.value.scheduling.maintenance_interval, null)
      /*
       * There's some sort of error in Terraform documentation
       *
      nanos = try(each.value.scheduling.nanos, null)
      seconds = try(each.value.scheduling.seconds, null)
      local_ssd_recovery_timeout = try(each.value.scheduling.local_ssd_recovery_timeout, null)
      seconds = try(each.value.scheduling.seconds, null)
      type = try(each.value.scheduling.type, null)
      count = try(each.value.scheduling.count, null)
      */

      # (Optional) Specifies node affinities or anti-affinities to determine which sole-tenant nodes your instances and managed instance groups will use as host systems.
      dynamic "node_affinities" {
        # (Optional) The scheduling strategy to use. 
        for_each = try(each.value.scheduling.node_affinities, null) == null ? [] : [1]

        content {
          key      = each.value.scheduling.node_affinities.key
          operator = each.value.scheduling.node_affinities.operator
          values   = each.value.scheduling.node_affinities.values
        }
      }
    }
  }

  dynamic "network_interface" {
    # (Required) Networks to attach to the instance. This can be specified multiple times. 
    for_each = coalesce(each.value.network_interface, [])

    content {
      network            = network_interface.value.network
      subnetwork         = network_interface.value.subnetwork
      subnetwork_project = network_interface.value.subnetwork_project
      network_ip         = network_interface.value.network_ip
      stack_type         = network_interface.value.stack_type
      queue_count        = network_interface.value.queue_count
      # network_attachment = network_interface.value.network_attachment
      # security_policy    = network_interface.value.security_policy

      dynamic "access_config" {
        # (Optional) Access configurations, i.e. IPs via which this instance can be accessed via the Internet. 
        # Omit to ensure that the instance is not accessible from the Internet. If omitted, ssh provisioners will 
        # not work unless Terraform can send traffic to the instance's network (e.g. via tunnel or because it is 
        # running on another cloud instance on that network). This block can be repeated multiple times.
        for_each = coalesce(network_interface.value.access_config, [])

        content {
          nat_ip                 = access_config.value.nat_ip
          public_ptr_domain_name = access_config.value.public_ptr_domain_name
          network_tier           = access_config.value.network_tier
        }
      }

      dynamic "ipv6_access_config" {
        # (Optional) An array of IPv6 access configurations for this interface. Currently, only one IPv6 access config, 
        # DIRECT_IPV6, is supported. If there is no ipv6AccessConfig specified, then this instance will have no 
        # external IPv6 Internet access. 
        for_each = coalesce(network_interface.value.ipv6_access_config, [])

        content {
          external_ipv6               = ipv6_access_config.value.external_ipv6
          external_ipv6_prefix_length = ipv6_access_config.value.external_ipv6_prefix_length
          name                        = ipv6_access_config.value.name
          network_tier                = ipv6_access_config.value.network_tier
          public_ptr_domain_name      = ipv6_access_config.value.public_ptr_domain_name
        }
      }

      dynamic "alias_ip_range" {
        # (Optional) An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks. 
        for_each = network_interface.value.alias_ip_range == null ? [] : [1]

        content {
          ip_cidr_range         = network_interface.value.alias_ip_range.ip_cidr_range
          subnetwork_range_name = network_interface.value.alias_ip_range.subnetwork_range_name
        }
      }
    }
  }

  dynamic "disk" {
    # (Required) Disks to attach to instances created from this template. This can be specified multiple times for multiple disks.
    for_each = each.value.disk

    content {
      auto_delete       = disk.value.auto_delete
      boot              = disk.value.boot
      device_name       = disk.value.device_name
      disk_name         = disk.value.disk_name
      provisioned_iops  = disk.value.provisioned_iops
      source_image      = disk.value.source_image
      source_snapshot   = disk.value.source_snapshot
      interface         = disk.value.interface
      mode              = disk.value.mode
      source            = disk.value.source
      disk_type         = disk.value.disk_type
      disk_size_gb      = disk.value.disk_size_gb
      labels            = disk.value.labels
      type              = disk.value.type
      resource_policies = disk.value.resource_policies

      dynamic "source_image_encryption_key" {
        # (Optional) The customer-supplied encryption key of the source image. Required if the source image is protected by a 
        # customer-supplied encryption key.
        #
        # Instance templates do not store customer-supplied encryption keys, so you cannot create disks for instances in a managed 
        # instance group if the source images are encrypted with your own keys. 
        for_each = disk.value.source_image_encryption_key == null ? [] : [1]

        content {
          kms_key_service_account = disk.value.source_image_encryption_key.kms_key_service_account
          kms_key_self_link       = disk.value.source_image_encryption_key.kms_key_self_link
        }
      }

      dynamic "source_snapshot_encryption_key" {
        # (Optional) The customer-supplied encryption key of the source snapshot.
        for_each = disk.value.source_snapshot_encryption_key == null ? [] : [1]

        content {
          kms_key_service_account = disk.value.source_snapshot_encryption_key.kms_key_service_account
          kms_key_self_link       = disk.value.source_snapshot_encryption_key.kms_key_self_link
        }
      }

      dynamic "disk_encryption_key" {
        # (Optional) Encrypts or decrypts a disk using a customer-supplied encryption key.
        #
        # If you are creating a new disk, this field encrypts the new disk using an encryption key that you provide. If you are
        # attaching an existing disk that is already encrypted, this field decrypts the disk using the customer-supplied encryption key.
        #
        # If you encrypt a disk using a customer-supplied key, you must provide the same key again when you attempt to use this 
        # resource at a later time. For example, you must provide the key when you create a snapshot or an image from the disk or 
        # when you attach the disk to a virtual machine instance.
        #
        # If you do not provide an encryption key, then the disk will be encrypted using an automatically generated key and you do 
        # not need to provide a key to use the disk later.
        #
        # Instance templates do not store customer-supplied encryption keys, so you cannot use your own keys to encrypt disks in a 
        # managed instance group. 
        for_each = disk.value.disk_encryption_key == null ? [] : [1]

        content {
          kms_key_self_link = disk.value.disk_encryption_key.kms_key_self_link
        }
      }
    }
  }
}
