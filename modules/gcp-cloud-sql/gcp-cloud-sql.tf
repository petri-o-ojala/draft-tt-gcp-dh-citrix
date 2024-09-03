#
# GCP Cloud SQL
#

resource "google_sql_database_instance" "lz" {
  #
  # Cloud SQL instances
  #
  for_each = {
    for csql in local.gcp_cloud_sql_instance : csql.resource_index => csql
  }


  database_version = each.value.database_version

  region               = each.value.region
  name                 = each.value.name
  maintenance_version  = each.value.maintenance_version
  master_instance_name = each.value.master_instance_name
  project              = each.value.project
  root_password        = each.value.root_password == null ? null : lookup(local.google_secret_manager_secret_version, each.value.root_password, null) == null ? each.value.root_password : local.google_secret_manager_secret_version[each.value.root_password].secret_data
  encryption_key_name  = each.value.encryption_key_name
  deletion_protection  = each.value.deletion_protection

  dynamic "settings" {
    # (Optional) The settings to use for the database.
    for_each = try(each.value.settings, null) == null ? [] : [1]

    content {
      tier                        = each.value.settings.tier
      edition                     = try(each.value.settings.edition, null)
      user_labels                 = try(each.value.settings.user_labels, null)
      activation_policy           = try(each.value.settings.activation_policy, null)
      availability_type           = try(each.value.settings.availability_type, null)
      collation                   = try(each.value.settings.collation, null)
      connector_enforcement       = try(each.value.settings.connector_enforcement, null)
      deletion_protection_enabled = try(each.value.settings.deletion_protection_enabled, null)
      disk_autoresize             = try(each.value.settings.disk_autoresize, null)
      disk_autoresize_limit       = try(each.value.settings.disk_autoresize_limit, null)
      disk_size                   = try(each.value.settings.disk_size, null)
      disk_type                   = try(each.value.settings.disk_type, null)
      pricing_plan                = try(each.value.settings.pricing_plan, null)
      time_zone                   = try(each.value.settings.time_zone, null)

      dynamic "advanced_machine_features" {
        for_each = try(each.value.settings.advanced_machine_features, null) == null ? [] : [1]

        content {
          threads_per_core = try(each.value.settings.advanced_machine_features.threads_per_core, null)
        }
      }

      dynamic "database_flags" {
        for_each = try(each.value.settings.database_flags, null) == null ? [] : [1]

        content {
          name  = each.value.settings.database_flags.name
          value = each.value.settings.database_flags.value
        }
      }

      dynamic "active_directory_config" {
        for_each = try(each.value.settings.active_directory_config, null) == null ? [] : [1]

        content {
          domain = each.value.settings.active_directory_config.domain
        }
      }

      dynamic "data_cache_config" {
        for_each = try(each.value.settings.data_cache_config, null) == null ? [] : [1]

        content {
          data_cache_enabled = try(each.value.settings.data_cache_config.data_cache_enabled, null)
        }
      }

      dynamic "deny_maintenance_period" {
        for_each = try(each.value.settings.deny_maintenance_period, null) == null ? [] : [1]

        content {
          end_date   = each.value.settings.deny_maintenance_period.end_date
          start_date = each.value.settings.deny_maintenance_period.start_date
          time       = each.value.settings.deny_maintenance_period.time
        }
      }

      dynamic "sql_server_audit_config" {
        for_each = try(each.value.settings.sql_server_audit_config, null) == null ? [] : [1]

        content {
          bucket             = try(each.value.settings.sql_server_audit_config.bucket, null)
          upload_interval    = try(each.value.settings.sql_server_audit_config.upload_interval, null)
          retention_interval = try(each.value.settings.sql_server_audit_config.retention_interval, null)
        }
      }

      dynamic "ip_configuration" {
        for_each = try(each.value.settings.ip_configuration, null) == null ? [] : [1]

        content {
          ipv4_enabled                                  = try(each.value.settings.ip_configuration.ipv4_enabled, null)
          private_network                               = try(each.value.settings.ip_configuration.private_network, null)
          require_ssl                                   = try(each.value.settings.ip_configuration.require_ssl, null)
          ssl_mode                                      = try(each.value.settings.ip_configuration.ssl_mode, null)
          allocated_ip_range                            = try(each.value.settings.ip_configuration.allocated_ip_range, null)
          enable_private_path_for_google_cloud_services = try(each.value.settings.ip_configuration.enable_private_path_for_google_cloud_services, null)

          dynamic "authorized_networks" {
            for_each = coalesce(each.value.settings.ip_configuration.authorized_networks, [])

            content {
              expiration_time = try(authorized_networks.value.expiration_time, null)
              name            = try(authorized_networks.value.name, null)
              value           = authorized_networks.value.value
            }
          }

          dynamic "psc_config" {
            for_each = try(each.value.settings.ip_configuration.psc_config, null) == null ? [] : [1]

            content {
              psc_enabled               = try(each.value.settings.ip_configuration.psc_config.psc_enabled, null)
              allowed_consumer_projects = try(each.value.settings.ip_configuration.psc_config.allowed_consumer_projects, null)
            }
          }
        }
      }

      dynamic "location_preference" {
        for_each = try(each.value.settings.location_preference, null) == null ? [] : [1]

        content {
          follow_gae_application = try(each.value.settings.location_preference.follow_gae_application, null)
          zone                   = try(each.value.settings.location_preference.zone, null)
          secondary_zone         = try(each.value.settings.location_preference.secondary_zone, null)
        }
      }

      dynamic "maintenance_window" {
        for_each = try(each.value.settings.maintenance_window, null) == null ? [] : [1]

        content {
          day          = try(each.value.settings.maintenance_window.day, null)
          hour         = try(each.value.settings.maintenance_window.hour, null)
          update_track = try(each.value.settings.maintenance_window.update_track, null)
        }
      }

      dynamic "insights_config" {
        for_each = try(each.value.settings.insights_config, null) == null ? [] : [1]

        content {
          query_insights_enabled  = try(each.value.settings.insights_config.query_insights_enabled, null)
          query_string_length     = try(each.value.settings.insights_config.query_string_length, null)
          record_application_tags = try(each.value.settings.insights_config.record_application_tags, null)
          record_client_address   = try(each.value.settings.insights_config.record_client_address, null)
          query_plans_per_minute  = try(each.value.settings.insights_config.query_plans_per_minute, null)
        }
      }

      dynamic "password_validation_policy" {
        for_each = try(each.value.settings.password_validation_policy, null) == null ? [] : [1]

        content {
          min_length                  = try(each.value.settings.password_validation_policy.min_length, null)
          complexity                  = try(each.value.settings.password_validation_policy.complexity, null)
          reuse_interval              = try(each.value.settings.password_validation_policy.reuse_interval, null)
          disallow_username_substring = try(each.value.settings.password_validation_policy.disallow_username_substring, null)
          password_change_interval    = try(each.value.settings.password_validation_policy.password_change_interval, null)
          enable_password_policy      = try(each.value.settings.password_validation_policy.enable_password_policy, null)
        }
      }

      dynamic "backup_configuration" {
        for_each = try(each.value.settings.backup_configuration, null) == null ? [] : [1]

        content {
          binary_log_enabled             = try(each.value.settings.backup_configuration.binary_log_enabled, null)
          enabled                        = try(each.value.settings.backup_configuration.enabled, null)
          start_time                     = try(each.value.settings.backup_configuration.start_time, null)
          point_in_time_recovery_enabled = try(each.value.settings.backup_configuration.point_in_time_recovery_enabled, null)
          location                       = try(each.value.settings.backup_configuration.location, null)
          transaction_log_retention_days = try(each.value.settings.backup_configuration.transaction_log_retention_days, null)

          dynamic "backup_retention_settings" {
            for_each = try(each.value.settings.backup_configuration.backup_retention_settings, null) == null ? [] : [1]

            content {
              retained_backups = try(each.value.settings.backup_configuration.backup_retention_settings.retained_backups, null)
              retention_unit   = try(each.value.settings.backup_configuration.backup_retention_settings.retention_unit, null)
            }
          }
        }
      }
    }
  }

  dynamic "replica_configuration" {
    # (Optional) The configuration for replication.
    for_each = try(each.value.replica_configuration, null) == null ? [] : [1]

    content {
      ca_certificate            = try(each.value.replica_configuration.ca_certificate, null)
      client_certificate        = try(each.value.replica_configuration.client_certificate, null)
      client_key                = try(each.value.replica_configuration.client_key, null)
      connect_retry_interval    = try(each.value.replica_configuration.connect_retry_interval, null)
      dump_file_path            = try(each.value.replica_configuration.dump_file_path, null)
      failover_target           = try(each.value.replica_configuration.failover_target, null)
      master_heartbeat_period   = try(each.value.replica_configuration.master_heartbeat_period, null)
      password                  = try(each.value.replica_configuration.password, null)
      ssl_cipher                = try(each.value.replica_configuration.ssl_cipher, null)
      username                  = try(each.value.replica_configuration.username, null)
      verify_server_certificate = try(each.value.replica_configuration.verify_server_certificate, null)
    }
  }

  dynamic "clone" {
    # (Optional) The context needed to create this instance as a clone of another instance. When this field is set during 
    # resource creation, Terraform will attempt to clone another instance as indicated in the context. 
    for_each = try(each.value.clone, null) == null ? [] : [1]

    content {
      source_instance_name = each.value.clone.source_instance_name
      point_in_time        = try(each.value.clone.point_in_time, null)
      preferred_zone       = try(each.value.clone.preferred_zone, null)
      database_names       = try(each.value.clone.database_names, null)
      allocated_ip_range   = try(each.value.clone.allocated_ip_range, null)
    }
  }

  dynamic "restore_backup_context" {
    # (optional) The context needed to restore the database to a backup run. This field will cause Terraform to trigger the 
    # database to restore from the backup run indicated. 
    for_each = try(each.value.restore_backup_context, null) == null ? [] : [1]

    content {
      backup_run_id = each.value.restore_backup_context.backup_run_id
      instance_id   = try(each.value.restore_backup_context.instance_id, null)
      project       = try(each.value.restore_backup_context.project, null)
    }
  }
}

resource "google_sql_database" "lz" {
  #
  # Cloud SQL instances
  #
  for_each = {
    for csql in local.gcp_cloud_sql_database : csql.resource_index => csql
  }

  name     = each.value.name
  instance = each.value.instance

  charset         = try(each.value.charset, null)
  collation       = try(each.value.collation, null)
  project         = try(each.value.project, null)
  deletion_policy = try(each.value.deletion_policy, null)
}

resource "google_sql_user" "lz" {
  #
  # Cloud SQL users
  #
  for_each = {
    for user in local.gcp_cloud_sql_user : user.resource_index => user
  }

  name     = each.value.name
  instance = each.value.instance

  password        = try(each.value.password, null)
  type            = try(each.value.type, null)
  deletion_policy = try(each.value.deletion_policy, null)
  host            = try(each.value.host, null)
  project         = try(each.value.project, null)

  dynamic "password_policy" {
    for_each = try(each.value.password_policy, null) == null ? [] : [1]

    content {
      allowed_failed_attempts      = try(each.value.password_policy.allowed_failed_attempts, null)
      password_expiration_duration = try(each.value.password_policy.password_expiration_duration, null)
      enable_failed_attempts_check = try(each.value.password_policy.enable_failed_attempts_check, null)
      enable_password_verification = try(each.value.password_policy.enable_password_verification, null)
    }
  }
}

resource "google_sql_ssl_cert" "lz" {
  #
  # Cloud SQL SSL Certificates
  #
  for_each = {
    for ssl_cert in local.gcp_cloud_sql_ssl_cert : ssl_cert.resource_index => ssl_cert
  }

  common_name = each.value.common_name
  instance    = each.value.instance
  project     = try(each.value.project, null)
}
