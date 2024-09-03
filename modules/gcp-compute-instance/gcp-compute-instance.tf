#
# GCP Compute Engine
#

locals {
  google_compute_instance = google_compute_instance.lz
}

data "cloudinit_config" "lz" {
  #
  # GCP Compute Instances
  #
  for_each = {
    for instance in local.gcp_compute_instance : instance.resource_index => instance
    if instance.cloudinit_config_file != null
  }

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = file(each.value.cloudinit_config_file)
    filename     = "cloudinit_config.yaml"
  }
}

resource "google_compute_instance" "lz" {
  #
  # GCP Compute Instances
  #
  for_each = {
    for instance in local.gcp_compute_instance : instance.resource_index => instance
  }

  lifecycle {
    ignore_changes = [
      attached_disk
    ]
  }

  name         = each.value.name
  machine_type = each.value.machine_type
  zone         = try(each.value.zone, null)
  project      = try(each.value.project, null)
  description  = try(each.value.description, null)
  hostname     = try(each.value.hostname, null)

  labels = try(each.value.labels, null)

  boot_disk {
    # (Required) The boot disk for the instance.
    auto_delete             = try(each.value.boot_disk.auto_delete, null)
    device_name             = try(each.value.boot_disk.device_name, null)
    mode                    = try(each.value.boot_disk.mode, null)
    disk_encryption_key_raw = try(each.value.boot_disk.disk_encryption_key_raw, null)
    kms_key_self_link       = try(each.value.boot_disk.kms_key_self_link, null)
    source                  = try(each.value.boot_disk.source, null)

    dynamic "initialize_params" {
      # (Optional) Parameters for a new disk that will be created alongside the new instance.
      # Either initialize_params or source must be set.
      for_each = try(each.value.boot_disk.initialize_params, null) == null ? [] : [1]

      content {
        size                  = try(each.value.boot_disk.initialize_params.size, null)
        type                  = try(each.value.boot_disk.initialize_params.type, null)
        image                 = try(each.value.boot_disk.initialize_params.image, null)
        labels                = try(each.value.boot_disk.initialize_params.labels, null)
        resource_manager_tags = try(each.value.boot_disk.initialize_params.resource_manager_tags, null)
      }
    }
  }
  dynamic "scratch_disk" {
    # (Optional) Scratch disks to attach to the instance. This can be specified multiple times for multiple scratch disks.
    for_each = coalesce(each.value.scratch_disk, [])

    content {
      interface = try(scratch_disk.value.interface, null)
    }
  }
  dynamic "attached_disk" {
    # (Optional) Additional disks to attach to the instance. Can be repeated multiple times for multiple disks.
    for_each = coalesce(each.value.attached_disk, [])

    content {
      source                  = attached_disk.value.source
      device_name             = try(attached_disk.value.device_name, null)
      mode                    = try(attached_disk.value.mode, null)
      disk_encryption_key_raw = try(attached_disk.value.disk_encryption_key_raw, null)
      kms_key_self_link       = try(attached_disk.value.kms_key_self_link, null)
    }
  }

  # (Required) Networks to attach to the instance. This can be specified multiple times. 
  dynamic "network_interface" {
    # (Required) Networks to attach to the instance. This can be specified multiple times. 
    for_each = coalesce(each.value.network_interface, [])

    content {
      network            = try(network_interface.value.network, null)
      subnetwork         = try(network_interface.value.subnetwork, null)
      subnetwork_project = try(network_interface.value.subnetwork_project, null)
      network_ip         = try(network_interface.value.network_ip, null)
      stack_type         = try(network_interface.value.stack_type, null)
      queue_count        = try(network_interface.value.queue_count, null)
      # network_attachment = try(network_interface.value.network_attachment, null)
      # security_policy    = try(network_interface.value.security_policy, null)

      dynamic "access_config" {
        # (Optional) Access configurations, i.e. IPs via which this instance can be accessed via the Internet. 
        # Omit to ensure that the instance is not accessible from the Internet. If omitted, ssh provisioners will 
        # not work unless Terraform can send traffic to the instance's network (e.g. via tunnel or because it is 
        # running on another cloud instance on that network). This block can be repeated multiple times.
        for_each = coalesce(network_interface.value.access_config, [])

        content {
          nat_ip                 = try(access_config.value.nat_ip, null)
          public_ptr_domain_name = try(access_config.value.public_ptr_domain_name, null)
          network_tier           = try(access_config.value.network_tier, null)
        }
      }

      dynamic "ipv6_access_config" {
        # (Optional) An array of IPv6 access configurations for this interface. Currently, only one IPv6 access config, 
        # DIRECT_IPV6, is supported. If there is no ipv6AccessConfig specified, then this instance will have no 
        # external IPv6 Internet access. 
        for_each = coalesce(network_interface.value.ipv6_access_config, [])

        content {
          external_ipv6               = try(ipv6_access_config.value.external_ipv6, null)
          external_ipv6_prefix_length = try(ipv6_access_config.value.external_ipv6_prefix_length, null)
          name                        = try(ipv6_access_config.value.name, null)
          network_tier                = try(ipv6_access_config.value.network_tier, null)
          public_ptr_domain_name      = try(ipv6_access_config.value.public_ptr_domain_name, null)
        }
      }

      dynamic "alias_ip_range" {
        # (Optional) An array of alias IP ranges for this network interface. Can only be specified for network interfaces on subnet-mode networks. 
        for_each = try(network_interface.value.alias_ip_range, null) == null ? [] : [1]

        content {
          ip_cidr_range         = try(network_interface.value.alias_ip_range.ip_cidr_range, null)
          subnetwork_range_name = try(network_interface.value.alias_ip_range.subnetwork_range_name, null)
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
  can_ip_forward = try(each.value.can_ip_forward, null)
  tags           = try(each.value.tags, null)

  allow_stopping_for_update = try(each.value.allow_stopping_for_update, null)
  desired_status            = try(each.value.desired_status, null)
  deletion_protection       = try(each.value.deletion_protection, null)
  guest_accelerator         = try(each.value.guest_accelerator, null)
  metadata = merge(
    try(each.value.metadata, null),
    each.value.cloudinit_config_file == null ? null : {
      user-data = data.cloudinit_config.lz[each.key].rendered
    }
  )

  metadata_startup_script = each.value.metadata_startup_script == null ? null : fileexists(each.value.metadata_startup_script) ? file(each.value.metadata_startup_script) : each.value.metadata_startup_script
  min_cpu_platform        = try(each.value.min_cpu_platform, null)
  enable_display          = try(each.value.enable_display, null)
  resource_policies       = try(each.value.resource_policies, null)

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

  dynamic "params" {
    # (Optional) Additional instance parameters.
    for_each = try(each.value.params, null) == null ? [] : [1]
    content {
      resource_manager_tags = try(each.value.params.resource_manager_tags, null)
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

  depends_on = [
    google_compute_disk.lz,
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_instance_iam_member" "instance" {
  #
  # GCP Compute Instances IAM
  #
  for_each = {
    for iam in local.gcp_compute_instance_iam : iam.resource_index => iam
  }

  instance_name = each.value.instance_name
  zone          = each.value.zone
  project       = try(each.value.project, null)
  role          = each.value.role
  member        = lookup(local.compute_service_account, each.value.member, null) == null ? each.value.member : google_service_account.compute[each.value.member].member

  depends_on = [
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_disk" "lz" {
  #
  # GCP Compute Engine Persistent Disks (Zonal)
  #
  for_each = {
    for disk in local.gcp_compute_disk : disk.resource_index => disk
    if disk.replica_zones == null
  }

  name        = each.value.name
  description = try(each.value.description, null)
  labels      = try(each.value.labels, null)

  project = try(each.value.project, null)
  zone    = try(each.value.zone, null)

  size                      = try(each.value.size, null)
  physical_block_size_bytes = try(each.value.physical_block_size_bytes, null)

  source_disk            = try(each.value.source_disk, null)
  type                   = try(each.value.type, null)
  image                  = try(each.value.image, null)
  provisioned_iops       = try(each.value.provisioned_iops, null)
  provisioned_throughput = try(each.value.provisioned_throughput, null)
  snapshot               = try(each.value.snapshot, null)
  # resource_policies              = try(each.value.resource_policies, null)
  # enable_confidential_compute    = try(each.value.enable_confidential_compute, null)
  # multi_writer                   = try(each.value.multi_writer, null)

  dynamic "disk_encryption_key" {
    # (Optional) Encrypts the disk using a customer-supplied encryption key. After you encrypt a disk with a 
    # customer-supplied key, you must provide the same key if you use the disk later (e.g. to create a disk
    # snapshot or an image, or to attach the disk to a virtual machine). Customer-supplied encryption keys 
    # do not protect access to metadata of the disk. If you do not provide an encryption key when creating 
    # the disk, then the disk will be encrypted using an automatically generated key and you do not need to 
    # provide a key to use the disk later.
    for_each = try(each.value.disk_encryption_key, null) == null ? [] : [1]

    content {
      raw_key                 = try(each.value.disk_encryption_key.raw_key, null)
      rsa_encrypted_key       = try(each.value.disk_encryption_key.rsa_encrypted_key, null)
      sha256                  = try(each.value.disk_encryption_key.sha256, null)
      kms_key_self_link       = try(each.value.disk_encryption_key.kms_key_self_link, null)
      kms_key_service_account = try(each.value.disk_encryption_key.kms_key_service_account, null)
    }
  }

  dynamic "source_snapshot_encryption_key" {
    # (Optional) The customer-supplied encryption key of the source snapshot. Required if the source snapshot 
    # is protected by a customer-supplied encryption key. 
    for_each = try(each.value.source_snapshot_encryption_key, null) == null ? [] : [1]

    content {
      raw_key                 = try(each.value.source_snapshot_encryption_key.raw_key, null)
      sha256                  = try(each.value.source_snapshot_encryption_key.sha256, null)
      kms_key_self_link       = try(each.value.source_snapshot_encryption_key.kms_key_self_link, null)
      kms_key_service_account = try(each.value.source_snapshot_encryption_key.kms_key_service_account, null)
    }
  }

  dynamic "source_image_encryption_key" {
    # (Optional) The customer-supplied encryption key of the source image. Required if the source image is protected 
    # by a customer-supplied encryption key. 
    for_each = try(each.value.source_image_encryption_key, null) == null ? [] : [1]

    content {
      raw_key                 = try(each.value.source_image_encryption_key.raw_key, null)
      sha256                  = try(each.value.source_image_encryption_key.sha256, null)
      kms_key_self_link       = try(each.value.source_image_encryption_key.kms_key_self_link, null)
      kms_key_service_account = try(each.value.source_image_encryption_key.kms_key_service_account, null)
    }
  }

  dynamic "guest_os_features" {
    # (Optional) A list of features to enable on the guest operating system. Applicable only for bootable disks.
    for_each = try(each.value.guest_os_features, null) == null ? [] : [1]

    content {
      type = each.value.guest_os_features.type
    }
  }

  dynamic "async_primary_disk" {
    #
    for_each = try(each.value.async_primary_disk, null) == null ? [] : [1]

    content {
      disk = each.value.async_primary_disk.disk
    }
  }
}

resource "google_compute_region_disk" "lz" {
  #
  # GCP Compute Engine Persistent Disks (Regional)
  #
  for_each = {
    for disk in local.gcp_compute_disk : disk.resource_index => disk
    if disk.replica_zones != null
  }

  name        = each.value.name
  description = try(each.value.description, null)
  labels      = try(each.value.labels, null)

  project       = try(each.value.project, null)
  replica_zones = each.value.replica_zones
  region        = each.value.region

  size                      = try(each.value.size, null)
  physical_block_size_bytes = try(each.value.physical_block_size_bytes, null)

  source_disk = try(each.value.source_disk, null)
  type        = try(each.value.type, null)
  snapshot    = each.value.snapshot
  licenses    = each.value.licenses

  # resource_policies              = try(each.value.resource_policies, null)
  # enable_confidential_compute    = try(each.value.enable_confidential_compute, null)
  # multi_writer                   = try(each.value.multi_writer, null)

  dynamic "disk_encryption_key" {
    # (Optional) Encrypts the disk using a customer-supplied encryption key. After you encrypt a disk with a 
    # customer-supplied key, you must provide the same key if you use the disk later (e.g. to create a disk
    # snapshot or an image, or to attach the disk to a virtual machine). Customer-supplied encryption keys 
    # do not protect access to metadata of the disk. If you do not provide an encryption key when creating 
    # the disk, then the disk will be encrypted using an automatically generated key and you do not need to 
    # provide a key to use the disk later.
    for_each = try(each.value.disk_encryption_key, null) == null ? [] : [1]

    content {
      raw_key = try(each.value.disk_encryption_key.raw_key, null)
      sha256  = try(each.value.disk_encryption_key.sha256, null)
    }
  }

  dynamic "source_snapshot_encryption_key" {
    # (Optional) The customer-supplied encryption key of the source snapshot. Required if the source snapshot 
    # is protected by a customer-supplied encryption key. 
    for_each = try(each.value.source_snapshot_encryption_key, null) == null ? [] : [1]

    content {
      raw_key = try(each.value.source_snapshot_encryption_key.raw_key, null)
      sha256  = try(each.value.source_snapshot_encryption_key.sha256, null)
    }
  }

  dynamic "guest_os_features" {
    # (Optional) A list of features to enable on the guest operating system. Applicable only for bootable disks.
    for_each = try(each.value.guest_os_features, null) == null ? [] : [1]

    content {
      type = each.value.guest_os_features.type
    }
  }

  dynamic "async_primary_disk" {
    #
    for_each = try(each.value.async_primary_disk, null) == null ? [] : [1]

    content {
      disk = each.value.async_primary_disk.disk
    }
  }
}

resource "google_compute_disk_iam_member" "compute_disk" {
  #
  # GCP Compute Engine Persistent Disks IAM (Zonal)
  #
  for_each = {
    for iam in local.gcp_compute_disk_iam : iam.resource_index => iam
    if iam.region == null
  }

  name    = each.value.name
  zone    = each.value.zone
  project = try(each.value.project, null)
  role    = each.value.role
  member  = lookup(local.compute_service_account, each.value.member, null) == null ? each.value.member : google_service_account.compute[each.value.member].member

  depends_on = [
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_region_disk_iam_member" "compute_disk" {
  #
  # GCP Compute Engine Persistent Disks IAM (Regional)
  #
  for_each = {
    for iam in local.gcp_compute_disk_iam : iam.resource_index => iam
    if iam.region != null
  }

  name    = each.value.name
  region  = each.value.region
  project = try(each.value.project, null)
  role    = each.value.role
  member  = lookup(local.compute_service_account, each.value.member, null) == null ? each.value.member : google_service_account.compute[each.value.member].member

  depends_on = [
    google_service_account.compute,
    google_service_account_iam_member.compute
  ]
}

resource "google_compute_attached_disk" "lz" {
  #
  # GCP Compute Disk attachments (Zonal)
  #
  for_each = {
    for disk_attachment in local.gcp_compute_disk_attachment : disk_attachment.resource_index => disk_attachment
  }

  disk     = google_compute_disk.lz[each.value.disk].name
  instance = google_compute_instance.lz[each.value.instance].name

  project     = try(each.value.project, null)
  zone        = try(each.value.zone, google_compute_instance.lz[each.value.instance].zone)
  device_name = try(each.value.device_name, null)
  mode        = try(each.value.mode, null)

  depends_on = [
    google_service_account.compute,
    google_service_account_iam_member.compute,
    google_compute_disk.lz,
    google_compute_region_disk.lz,
    google_compute_instance.lz
  ]
}
