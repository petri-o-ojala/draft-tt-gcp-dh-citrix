#
# GCP Compute Engine
#
variable "compute_instance_group" {
  description = "GCE Instance Group configurations"
  type = object({
    group = optional(map(object({
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group
      name        = string
      zone        = string
      description = optional(string)
      project     = optional(string)
      instances   = optional(list(string))
      network     = optional(string)
      named_port = optional(list(object({
        name = string
        port = string
      })))
    })))
    autoscaler = optional(map(object({
      zone        = optional(string)
      region      = optional(string)
      name        = optional(string)
      description = optional(string)
      project     = optional(string)
      target      = optional(string)
      autoscaling_policy = optional(list(object({
        min_replicas    = optional(number)
        max_replicas    = optional(number)
        cooldown_period = optional(number)
        mode            = optional(string)
        scale_down_control = optional(object({
          time_window_sec = optional(number)
          max_scaled_down_replicas = optional(object({
            fixed   = optional(number)
            percent = optional(number)
          }))
        }))
        scale_in_control = optional(object({
          time_window_sec = optional(number)
          max_scaled_down_replicas = optional(object({
            fixed   = optional(number)
            percent = optional(number)
          }))
        }))
        cpu_utilization = optional(object({
          target            = optional(string)
          predictive_method = optional(string)
        }))
        metric = optional(object({
          name                       = optional(string)
          target                     = optional(string)
          type                       = optional(string)
          single_instance_assignment = optional(string)
          filter                     = optional(string)
        }))
        load_balancing_utilization = optional(object({
          target = optional(string)
        }))
        scaling_schedules = optional(object({
          name                  = optional(string)
          min_required_replicas = optional(number)
          schedule              = optional(string)
          time_zone             = optional(string)
          duration_sec          = optional(number)
          disabled              = optional(bool)
          description           = optional(string)
        }))
      })))
    })))
    health_check = optional(map(object({
      region              = optional(string)
      name                = optional(string)
      check_interval_sec  = optional(number)
      description         = optional(string)
      healthy_threshold   = optional(number)
      timeout_sec         = optional(number)
      unhealthy_threshold = optional(number)
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
    manager = optional(map(object({
      zone                           = optional(string)
      region                         = optional(string)
      base_instance_name             = optional(string)
      name                           = optional(string)
      description                    = optional(string)
      project                        = optional(string)
      target_size                    = optional(string)
      list_managed_instances_results = optional(string)
      target_pools                   = optional(list(string))
      wait_for_instances             = optional(string)
      wait_for_instances_status      = optional(string)
      version = optional(list(object({
        name              = optional(string)
        instance_template = optional(string)
        target_size = optional(object({
          fixed   = optional(number)
          percent = optional(number)
        }))
      })))
      update_policy = optional(object({
        minimal_action                 = optional(string)
        most_disruptive_allowed_action = optional(string)
        type                           = optional(string)
        max_surge_fixed                = optional(number)
        max_surge_percent              = optional(number)
        max_unavailable_fixed          = optional(number)
        max_unavailable_percent        = optional(number)
        min_ready_sec                  = optional(number)
        replacement_method             = optional(string)
      }))
      all_instances_config = optional(object({
        metadata = optional(map(string))
        labels   = optional(map(string))
      }))
      named_port = optional(list(object({
        name = optional(string)
        port = optional(number)
      })))
      auto_healing_policies = optional(object({
        health_check      = optional(string)
        initial_delay_sec = optional(number)
      }))
      stateful_disk = optional(list(object({
        device_name = optional(string)
        delete_rule = optional(string)
      })))
      stateful_internal_ip = optional(list(object({
        interface_name = optional(string)
        delete_rule    = optional(string)
      })))
      stateful_external_ip = optional(list(object({
        interface_name = optional(string)
        delete_rule    = optional(string)
      })))
    })))
    template = optional(map(object({
      regional                = optional(bool)
      project                 = optional(string)
      region                  = optional(string)
      name                    = optional(string)
      name_prefix             = optional(string)
      description             = optional(string)
      labels                  = optional(map(string))
      cloudinit_config_file   = optional(string)
      metadata                = optional(map(string))
      metadata_startup_script = optional(string)
      machine_type            = optional(string)
      can_ip_forward          = optional(bool)
      instance_description    = optional(string)
      resource_policies       = optional(list(string))
      tags                    = optional(list(string))
      min_cpu_platform        = optional(string)
      enable_display          = optional(bool)
      guest_accelerator = optional(object({
        type  = optional(string)
        count = optional(number)
        local_ssd_recovery_timeout = optional(object({
          nanos   = optional(number)
          seconds = optional(number)
        }))
      }))
      shielded_instance_config = optional(object({
        enable_secure_boot          = optional(bool)
        enable_vtpm                 = optional(bool)
        enable_integrity_monitoring = optional(bool)
      }))
      confidential_instance_config = optional(object({
        enable_confidential_compute = optional(bool)
      }))
      advanced_machine_features = optional(object({
        enable_nested_virtualization = optional(bool)
        threads_per_core             = optional(number)
        visible_core_count           = optional(number)
      }))
      reservation_affinity = optional(object({
        type = optional(string)
        specific_reservation = optional(object({
          key    = optional(string)
          values = optional(string)
        }))
      }))
      network_performance_config = optional(object({
        total_egress_bandwidth_tier = optional(string)
      }))
      service_account = optional(object({
        email  = optional(string)
        scopes = optional(list(string))
      }))
      scheduling = optional(object({
        preemptible                 = optional(bool)
        on_host_maintenance         = optional(string)
        automatic_restart           = optional(bool)
        min_node_cpus               = optional(number)
        provisioning_model          = optional(string)
        instance_termination_action = optional(string)
        max_run_duration            = optional(string)
        maintenance_interval        = optional(string)
        node_affinities = optional(object({
          key      = optional(string)
          operator = optional(string)
          values   = optional(list(string))
        }))
      }))
      network_interface = optional(list(object({
        network            = optional(string)
        subnetwork         = optional(string)
        subnetwork_project = optional(string)
        network_ip         = optional(string)
        stack_type         = optional(string)
        queue_count        = optional(number)
        network_attachment = optional(string)
        security_policy    = optional(string)
        access_config = optional(list(object({
          nat_ip                 = optional(string)
          public_ptr_domain_name = optional(string)
          network_tier           = optional(string)
        })))
        ipv6_access_config = optional(list(object({
          external_ipv6               = optional(string)
          external_ipv6_prefix_length = optional(number)
          name                        = optional(string)
          network_tier                = optional(string)
          public_ptr_domain_name      = optional(string)
        })))
        alias_ip_range = optional(object({
          ip_cidr_range         = optional(string)
          subnetwork_range_name = optional(string)
        }))
      })))
      disk = list(object({
        auto_delete       = optional(string)
        boot              = optional(bool)
        device_name       = optional(string)
        disk_name         = optional(string)
        provisioned_iops  = optional(number)
        source_image      = optional(string)
        source_snapshot   = optional(string)
        interface         = optional(string)
        mode              = optional(string)
        source            = optional(string)
        disk_type         = optional(string)
        disk_size_gb      = optional(number)
        labels            = optional(map(string))
        type              = optional(string)
        resource_policies = optional(list(string))
        source_image_encryption_key = optional(object({
          kms_key_service_account = optional(string)
          kms_key_self_link       = optional(string)
        }))
        source_snapshot_encryption_key = optional(object({
          kms_key_service_account = optional(string)
          kms_key_self_link       = optional(string)
        }))
        disk_encryption_key = optional(object({
          kms_key_self_link = optional(string)
        }))
      }))
    })))
  })
  default = {}
}

locals {
  compute_instance_template      = coalesce(try(var.compute_instance_group.template, null), {})
  compute_instance_group_manager = coalesce(try(var.compute_instance_group.manager, null), {})
  compute_health_check           = coalesce(try(var.compute_instance_group.health_check, null), {})
  compute_autoscaler             = coalesce(try(var.compute_instance_group.autoscaler, null), {})

  #
  # GCP Compute Instance Groups
  #
  gcp_compute_instance_group = flatten([
    for group_id, group in coalesce(try(var.compute_instance_group.group, null), {}) : merge(
      group,
      {
        resource_index = join("_", [group_id])
      }
    )
  ])

  #
  # GCP Compute Instance Group Templates
  #
  gcp_compute_instance_template = flatten([
    for template_id, template in local.compute_instance_template : merge(
      template,
      {
        resource_index = join("_", [template_id])
      }
    )
  ])

  #
  # GCP Compute Instance Group Managers
  #
  gcp_compute_instance_group_manager = flatten([
    for manager_id, manager in local.compute_instance_group_manager : merge(
      manager,
      {
        resource_index = join("_", [manager_id])
      }
    )
  ])

  #
  # GCP Compute Instance Group Health Checks
  #
  gcp_compute_health_check = flatten([
    for health_check_id, health_check in local.compute_health_check : merge(
      health_check,
      {
        resource_index = join("_", [health_check_id])
      }
    )
  ])

  #
  # GCP Compute Instance Group Autoscalers
  #
  gcp_compute_autoscaler = flatten([
    for autoscaler_id, autoscaler in local.compute_autoscaler : merge(
      autoscaler,
      {
        resource_index = join("_", [autoscaler_id])
      }
    )
  ])
}
