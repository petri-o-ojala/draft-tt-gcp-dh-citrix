#
# GCP Compute Engine
#

variable "compute" {
  description = "GCE configurations"
  type = object({
    resource_policy = optional(map(object({
      name        = string
      description = optional(string)
      region      = optional(string)
      project     = optional(string)
      snapshot_schedule_policy = optional(object({
        snapshot_properties = optional(object({
          labels            = optional(map(string))
          storage_locations = optional(list(string))
          guest_flush       = optional(bool)
          chain_name        = optional(string)
        }))
        retention_policy = optional(object({
          max_retention_days    = optional(number)
          on_source_disk_delete = optional(string)
        }))
        schedule = optional(object({
          hourly_schedule = optional(object({
            hours_in_cycle = optional(number)
            start_time     = optional(string)
          }))
          daily_schedule = optional(object({
            days_in_cycle = optional(number)
            start_time    = optional(string)
          }))
          weekly_schedule = optional(object({
            day_of_weeks = optional(object({
              start_time = optional(string)
              day        = optional(string)
            }))
          }))
        }))
      }))
      group_placement_policy = optional(object({
        vm_count                  = optional(number)
        availability_domain_count = optional(number)
        collocation               = optional(string)
        max_distance              = optional(number)
      }))
      instance_schedule_policy = optional(object({
        time_zone       = optional(string)
        start_time      = optional(string)
        expiration_time = optional(string)
        vm_start_schedule = optional(object({
          schedule = string
        }))
        vm_stop_schedule = optional(object({
          schedule = string
        }))
      }))
      disk_consistency_group_policy = optional(object({
        enabled = bool
      }))
    })))
    service_account = optional(map(object({
      account_id   = string
      project      = optional(string)
      display_name = optional(string)
      description  = optional(string)
      disabled     = optional(bool)
      key = optional(object({
        rotation_days    = optional(number)
        key_algorithm    = optional(string)
        public_key_type  = optional(string)
        private_key_type = optional(string)
        public_key_data  = optional(string)
      }))
      service_account_iam = optional(list(object({
        role    = optional(string)
        member  = optional(list(string))
        project = optional(string)
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })))
      iam = optional(list(object({
        #
        # When using, define the target resource for this IAM assignment
        #
        project_id          = optional(string)
        storage_bucket_name = optional(string)
        folder_id           = optional(string)
        org_id              = optional(string)
        billing_account_id  = optional(string)
        managed_zone_name   = optional(string)
        project             = optional(string)
        subnetwork          = optional(string)
        role                = optional(list(string))
        policy_data         = optional(string)
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
    }))) })))
    instance = optional(map(object({
      name                  = string
      machine_type          = optional(string)
      zone                  = optional(string)
      project               = optional(string)
      description           = optional(string)
      hostname              = optional(string)
      labels                = optional(map(string))
      cloudinit_config_file = optional(string)
      boot_disk = object({
        auto_delete             = optional(bool)
        device_name             = optional(string)
        mode                    = optional(string)
        disk_encryption_key_raw = optional(string)
        kms_key_self_link       = optional(string)
        source                  = optional(string)
        initialize_params = optional(object({
          size                  = optional(number)
          type                  = optional(string)
          image                 = optional(string)
          labels                = optional(map(string))
          resource_manager_tags = optional(map(string))
        }))
      })
      scratch_disk = optional(list(object({
        interface = optional(string)
      })))
      attached_disk = optional(list(object({
        source                  = string
        device_name             = optional(string)
        mode                    = optional(string)
        disk_encryption_key_raw = optional(string)
        kms_key_self_link       = optional(string)
      })))
      network_interface = optional(list(object({
        network            = optional(string)
        subnetwork         = optional(string)
        subnetwork_project = optional(string)
        network_ip         = optional(string)
        stack_type         = optional(string)
        queue_count        = optional(number)
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
          subnetwork_range_name = optional(number)
        }))
      })))
      network_performance_config = optional(object({
        total_egress_bandwidth_tier = optional(string)
      }))
      can_ip_forward            = optional(bool)
      tags                      = optional(list(string))
      allow_stopping_for_update = optional(bool)
      desired_status            = optional(string)
      deletion_protection       = optional(bool)
      metadata                  = optional(map(string))
      metadata_startup_script   = optional(string)
      min_cpu_platform          = optional(string)
      resource_policies         = optional(list(string))
      enable_display            = optional(bool)
      service_account = optional(object({
        email  = optional(string)
        scopes = list(string)
      }))
      scheduling = optional(object({
        preemptible                 = optional(bool)
        on_host_maintenance         = optional(bool)
        automatic_restart           = optional(bool)
        min_node_cpus               = optional(number)
        provisioning_model          = optional(string)
        instance_termination_action = optional(string)
        node_affinities = optional(object({
          key      = string
          operator = string
          values   = list(string)
        }))
      }))
      params = optional(object({
        resource_manager_tags = optional(map(string))
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
          key    = string
          values = list(string)
        }))
      }))
      iam = optional(list(object({
        role    = optional(string)
        member  = optional(list(string))
        project = optional(string)
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })))
      iap = optional(map(object({
        scope           = string
        role            = optional(string)
        service_account = optional(string)
        member          = optional(list(string))
      })))
      disk = optional(map(object({
        name                      = string
        description               = optional(string)
        labels                    = optional(map(string))
        project                   = optional(string)
        replica_zones             = optional(list(string))
        zone                      = optional(string)
        size                      = optional(number)
        physical_block_size_bytes = optional(number)
        source_disk               = optional(string)
        type                      = optional(string)
        image                     = optional(string)
        provisioned_iops          = optional(number)
        provisioned_throughput    = optional(number)
        snapshot                  = optional(string)
        disk_encryption_key = optional(object({
          raw_key                 = optional(string)
          rsa_encrypted_key       = optional(string)
          sha256                  = optional(string)
          kms_key_self_link       = optional(string)
          kms_key_service_account = optional(string)
        }))
        source_snapshot_encryption_key = optional(object({
          raw_key                 = optional(string)
          sha256                  = optional(string)
          kms_key_self_link       = optional(string)
          kms_key_service_account = optional(string)
        }))
        source_image_encryption_key = optional(object({
          raw_key                 = optional(string)
          sha256                  = optional(string)
          kms_key_self_link       = optional(string)
          kms_key_service_account = optional(string)
        }))
        guest_os_features = optional(object({
          type = string
        }))
        async_primary_disk = optional(object({
          disk = string
        }))
        iam = optional(list(object({
          role    = optional(string)
          member  = optional(list(string))
          project = optional(string)
          condition = optional(object({
            expression  = string
            title       = string
            description = optional(string)
          }))
        })))
      })))
      dns = optional(list(object({
        name                  = optional(string)
        instance              = optional(string)
        instance_hostname     = optional(bool)
        type                  = optional(string, "A")
        ttl                   = optional(number, 300)
        managed_zone          = string
        project               = optional(string)
        rr_data_address       = optional(bool)
        rr_data_address_index = optional(number, 0)
        rr_data               = optional(list(string))
      })))
    })))
    disk = optional(map(object({
      name = string
      attachment = optional(object({
        instance    = string
        device_name = optional(string)
        mode        = optional(string)
      }))
      resource_policy           = optional(string)
      description               = optional(string)
      labels                    = optional(map(string))
      project                   = optional(string)
      zone                      = optional(string)
      region                    = optional(string)
      replica_zones             = optional(list(string))
      size                      = optional(number)
      physical_block_size_bytes = optional(number)
      source_disk               = optional(string)
      type                      = optional(string)
      image                     = optional(string)
      provisioned_iops          = optional(number)
      provisioned_throughput    = optional(number)
      snapshot                  = optional(string)
      disk_encryption_key = optional(object({
        raw_key                 = optional(string)
        rsa_encrypted_key       = optional(string)
        sha256                  = optional(string)
        kms_key_self_link       = optional(string)
        kms_key_service_account = optional(string)
      }))
      source_snapshot_encryption_key = optional(object({
        raw_key                 = optional(string)
        sha256                  = optional(string)
        kms_key_self_link       = optional(string)
        kms_key_service_account = optional(string)
      }))
      source_image_encryption_key = optional(object({
        raw_key                 = optional(string)
        sha256                  = optional(string)
        kms_key_self_link       = optional(string)
        kms_key_service_account = optional(string)
      }))
      guest_os_features = optional(object({
        type = string
      }))
      async_primary_disk = optional(object({
        disk = string
      }))
      iam = optional(list(object({
        role    = optional(string)
        member  = optional(list(string))
        project = optional(string)
        condition = optional(object({
          expression  = string
          title       = string
          description = optional(string)
        }))
      })))
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
      dns = optional(object({
        name              = optional(string)
        instance          = optional(string)
        instance_hostname = optional(bool)
        type              = optional(string, "A")
        ttl               = optional(number, 300)
        managed_zone      = string
        project           = optional(string)
        rr_data_address   = optional(bool)
        rr_data           = optional(list(string))
      }))
    })))
  })
  default = {}
}

variable "compute_json_configuration_file" {
  description = "JSON configuration file for GCP Compute Engine"
  type        = string
  default     = "gcp-compute-engine.json"
}

variable "compute_yaml_configuration_file" {
  description = "YAML configuration file for GCP Compute Engine"
  type        = string
  default     = "gcp-compute-engine.yaml"
}


locals {
  #
  # Support for JSON, YAML and variable configuration
  #
  compute_json_configuration = fileexists("${path.root}/${var.compute_json_configuration_file}") ? jsondecode(file("${path.root}/${var.compute_json_configuration_file}")) : {}
  compute_yaml_configuration = fileexists("${path.root}/${var.compute_yaml_configuration_file}") ? yamldecode(file("${path.root}/${var.compute_yaml_configuration_file}")) : {}

  compute_instance = merge(
    coalesce(try(var.compute.instance, null), {}),
    try(local.compute_json_configuration.compute.instance, {}),
    try(local.compute_yaml_configuration.compute.instance, {}),
  )
  compute_disk = merge(
    coalesce(try(var.compute.disk, null), {}),
    try(local.compute_json_configuration.compute.disk, {}),
    try(local.compute_yaml_configuration.compute.disk, {}),
  )
  compute_address = merge(
    coalesce(try(var.compute.address, null), {}),
    try(local.compute_json_configuration.compute.address, {}),
    try(local.compute_yaml_configuration.compute.address, {}),
  )
  compute_service_account = merge(
    coalesce(try(var.compute.service_account, null), {}),
    try(local.compute_json_configuration.compute.service_account, {}),
    try(local.compute_yaml_configuration.compute.service_account, {}),
  )
  compute_resource_policy = merge(
    coalesce(try(var.compute.resource_policy, null), {}),
    try(local.compute_json_configuration.compute.resource_policy, {}),
    try(local.compute_yaml_configuration.compute.resource_policy, {}),
  )
  #
  # GCP Compute Instances
  #
  gcp_compute_instance = flatten([
    for compute_instance_id, compute_instance in coalesce(try(local.compute_instance, null), {}) : merge(
      compute_instance,
      {
        resource_index = join("_", [compute_instance_id])
      }
    )
  ])

  #
  # GCP Compute Disks
  #
  gcp_compute_disk = flatten(concat(
    [
      # Individual disks
      for compute_disk_id, compute_disk in coalesce(try(local.compute_disk, null), {}) : merge(
        compute_disk,
        {
          compute_disk_id = compute_disk_id
          resource_index  = join("_", [compute_disk_id])
        }
      )
    ],
    flatten([
      # Disks attached to instances
      for compute_instance_id, compute_instance in coalesce(try(local.compute_instance, null), {}) : [
        for compute_disk_id, compute_disk in coalesce(try(compute_instance.disk, null), {}) : merge(
          compute_disk,
          {
            attachment          = null
            region              = null
            compute_instance_id = compute_instance_id
            compute_disk_id     = compute_disk_id
            resource_index      = join("_", [compute_instance_id, compute_disk_id])
          }
        )
      ]
    ])
  ))

  #
  # GCP Compute Instances IAM assignments
  # 
  gcp_compute_instance_iam = flatten([
    for compute_instance_id, compute_instance in coalesce(try(local.compute_instance, null), {}) : [
      for iam in coalesce(try(compute_instance.iam, null), []) : [
        for member in coalesce(try(iam.member, null), []) : {
          member         = member
          role           = iam.role
          condition      = iam.condition
          instance_name  = coalesce(compute_instance.name, google_compute_instance.lz[join("_", [compute_instance_id])].name)
          project        = coalesce(compute_instance.project, google_compute_instance.lz[join("_", [compute_instance_id])].project)
          zone           = coalesce(compute_instance.zone, google_compute_instance.lz[join("_", [compute_instance_id])].zone)
          resource_index = join("_", [compute_instance_id, iam.role, member])
        }
      ]
    ]
  ])

  #
  # GCP Compute Disks IAM assignments
  # 
  gcp_compute_disk_iam = flatten([
    for compute_disk_id, compute_disk in coalesce(try(local.compute_disk, null), {}) : [
      for iam in coalesce(try(compute_disk.iam, null), []) : [
        for member in coalesce(try(iam.member, null), []) : {
          member         = member
          role           = iam.role
          condition      = iam.condition
          region         = compute_disk.region
          name           = coalesce(compute_disk.name, google_compute_disk.lz[join("_", [compute_disk_id])].name)
          project        = coalesce(compute_disk.project, google_compute_disk.lz[join("_", [compute_disk_id])].project)
          zone           = coalesce(compute_disk.zone, google_compute_disk.lz[join("_", [compute_disk_id])].zone)
          resource_index = join("_", [compute_disk_id, iam.role, member])
        }
      ]
    ]
  ])

  #
  # GCP Compute Disk attachments
  #
  gcp_compute_disk_attachment = flatten([
    for compute_disk in local.gcp_compute_disk : merge(
      compute_disk.attachment,
      {
        project        = coalesce(compute_disk.project, google_compute_instance.lz[join("_", [compute_disk.attachment.instance])].project)
        zone           = coalesce(compute_disk.zone, google_compute_instance.lz[join("_", [compute_disk.attachment.instance])].zone)
        disk           = compute_disk.resource_index
        instance       = compute_disk.attachment.instance
        region         = null
        resource_index = join("_", [compute_disk.attachment.instance, compute_disk.compute_disk_id])
      }
    )
    if compute_disk.attachment != null
  ])

  #
  # GCP Compute Resource Policies
  #
  gcp_compute_resource_policy = flatten([
    for resource_policy_id, resource_policy in coalesce(try(local.compute_resource_policy, null), {}) : merge(
      resource_policy,
      {
        resource_index = join("_", [resource_policy_id])
      }
    )
  ])

  #
  # GCP Compute Disk resource policy attachments
  #
  gcp_compute_disk_resource_policy_attachment = flatten([
    for compute_disk in local.gcp_compute_disk :
    {
      disk_name      = compute_disk.resource_index
      policy_name    = compute_disk.resource_policy
      region         = compute_disk.region
      resource_index = join("_", [compute_disk.resource_policy, compute_disk.compute_disk_id])
    }
    if compute_disk.resource_policy != null
  ])

  #
  # GCP Compute Address allocations
  #
  gcp_compute_address = flatten([
    for compute_address_id, compute_address in coalesce(try(local.compute_address, null), {}) : merge(
      compute_address,
      {
        resource_index = join("_", [compute_address_id])
      }
    )
  ])

  #
  # Service Accounts for GCP Compute Engine resources
  #
  gcp_compute_service_account = flatten([
    for service_account_name, service_account in coalesce(try(local.compute_service_account, null), {}) : merge(
      service_account,
      {
        service_account_name = service_account_name
        resource_index       = join(":", [service_account_name])
      }
    )
  ])

  #
  # Service Accounts for GCP Compute Engine resources IAM assignments
  #

  gcp_compute_service_account_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.compute_service_account, null), {}) : [
      for iam in coalesce(try(service_account.service_account_iam, null), []) : [
        for member in coalesce(try(iam.member, null), []) : {
          member          = member
          role            = iam.role
          condition       = iam.condition
          service_account = service_account_name
          resource_index  = join("_", [service_account_name, iam.role, member])
        }
      ]
    ]
  ])

  #
  # Compute Service Account IAM permissions to project
  #
  gcp_compute_project_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.compute_service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          project_id     = iam.project_id
          role           = role
          member         = service_account_name
          resource_index = join("_", [service_account_name, iam.project_id, role])
        }
      ]
      if iam.project_id != null
    ]
  ])
}
