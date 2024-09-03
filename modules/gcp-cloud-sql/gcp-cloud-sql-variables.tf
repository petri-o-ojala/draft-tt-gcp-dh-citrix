#
# GCP Cloud SQL
#

variable "cloud_sql" {
  description = "Cloud SQL configurations"
  type = object(
    {
      secret = optional(map(object({
        #
        # Secret Manager Secret
        #
        secret_id = string
        replication = object({
          auto = optional(object({
            customer_managed_encryption = optional(object({
              kms_key_name = string
            }))
          }))
          user_managed = optional(object({
            replicas = optional(list(object({
              location = string
              customer_managed_encryption = optional(object({
                kms_key_name = string
              }))
            })))
          }))
        })
        project         = optional(string)
        labels          = optional(map(string))
        annotations     = optional(map(string))
        version_aliases = optional(map(string))
        topics = optional(list(object({
          name = string
        })))
        expire_time = optional(string)
        ttl         = optional(string)
        rotation = optional(object({
          next_rotation_time = optional(string)
          rotation_period    = optional(string)
        }))
        #
        # Secret Manager version (content)
        #
        secret_data = optional(string)
        secret_version = optional(object({
          enabled               = optional(bool)
          deletion_policy       = optional(string)
          is_secret_data_base64 = optional(bool)
        }))
        random_password = optional(object({
          length           = optional(number)
          upper            = optional(bool)
          min_upper        = optional(number)
          lower            = optional(bool)
          min_lower        = optional(number)
          numeric          = optional(bool)
          min_numeric      = optional(number)
          special          = optional(bool)
          override_special = optional(string)
          min_special      = optional(number)
        }))
      })))
      instance = optional(map(object({
        instance             = optional(bool, true)
        region               = optional(string)
        database_version     = string
        name                 = optional(string)
        maintenance_version  = optional(string)
        master_instance_name = optional(string)
        project              = optional(string)
        root_password        = optional(string)
        encryption_key_name  = optional(string)
        deletion_protection  = optional(bool)
        settings = optional(object({
          tier                        = string
          edition                     = optional(string)
          user_labels                 = optional(map(string))
          activation_policy           = optional(string)
          availability_type           = optional(string)
          collation                   = optional(string)
          connector_enforcement       = optional(string)
          deletion_protection_enabled = optional(bool)
          disk_autoresize             = optional(bool)
          disk_autoresize_limit       = optional(number)
          disk_size                   = optional(number)
          disk_type                   = optional(string)
          pricing_plan                = optional(string)
          time_zone                   = optional(string)
          advanced_machine_features = optional(object({
            threads_per_core = optional(number)
          }))
          database_flags = optional(object({
            name  = string
            value = string
          }))
          active_directory_config = optional(object({
            domain = string
          }))
          data_cache_config = optional(object({
            data_cache_enabled = optional(bool)
          }))
          deny_maintenance_period = optional(object({
            end_date   = string
            start_date = string
            time       = string
          }))
          sql_server_audit_config = optional(object({
            bucket             = optional(string)
            upload_interval    = optional(string)
            retention_interval = optional(string)
          }))
          ip_configuration = optional(object({
            ipv4_enabled                                  = optional(bool)
            private_network                               = optional(string)
            require_ssl                                   = optional(bool)
            ssl_mode                                      = optional(string)
            allocated_ip_range                            = optional(string)
            enable_private_path_for_google_cloud_services = optional(bool)
            authorized_networks = optional(list(object({
              expiration_time = optional(string)
              name            = optional(string)
              value           = string
            })))
            psc_config = optional(object({
              psc_enabled               = optional(bool)
              allowed_consumer_projects = optional(list(string))
            }))
          }))
          backup_configuration = optional(object({
            binary_log_enabled             = optional(bool)
            enabled                        = optional(bool)
            start_time                     = optional(string)
            point_in_time_recovery_enabled = optional(bool)
            location                       = optional(string)
            transaction_log_retention_days = optional(number)
            backup_retention_settings = optional(object({
              retained_backups = optional(string)
              retention_unit   = optional(string)
            }))
          }))
        }))
        replica_configuration = optional(object({
          ca_certificate            = optional(string)
          client_certificate        = optional(string)
          client_key                = optional(string)
          connect_retry_interval    = optional(number)
          dump_file_path            = optional(string)
          failover_target           = optional(string)
          master_heartbeat_period   = optional(number)
          password                  = optional(string)
          ssl_cipher                = optional(string)
          username                  = optional(string)
          verify_server_certificate = optional(bool)
        }))
        clone = optional(object({
          source_instance_name = optional(string)
          point_in_time        = optional(string)
          preferred_zone       = optional(string)
          database_names       = optional(list(string))
          allocated_ip_range   = optional(string)
        }))
        restore_backup_context = optional(object({
          backup_run_id = optional(string)
          instance_id   = optional(string)
          project       = optional(string)
        }))
        database = optional(map(object({
          name            = string
          instance        = optional(string)
          charset         = optional(string)
          collation       = optional(string)
          project         = optional(string)
          deletion_policy = optional(string)
        })))
        user = optional(list(object({
          instance        = optional(string)
          name            = string
          password        = optional(string)
          type            = optional(string)
          deletion_policy = optional(string)
          host            = optional(string)
          project         = optional(string)
          password_policy = optional(object({
            allowed_failed_attempts      = optional(number)
            password_expiration_duration = optional(number)
            enable_failed_attempts_check = optional(bool)
            enable_password_verification = optional(bool)
          }))
        })))
        ssl_cert = optional(list(object({
          common_name = string
          instance    = optional(string)
          project     = optional(string)
        })))
      })))
    }
  )
  default = {}
}

locals {
  cloud_sql = var.cloud_sql

  #
  # Secrets for Cloud SQL
  #
  gcp_secret_manager_secret = flatten([
    for secret_manager_id, secret_manager in coalesce(try(local.cloud_sql.secret, null), {}) : merge(
      secret_manager,
      {
        resource_index = join("_", [secret_manager_id])
      }
    )
  ])

  #
  # GCP Cloud SQL Instances
  #
  gcp_cloud_sql_instance = flatten([
    for sql_instance_id, sql_instance in coalesce(try(local.cloud_sql.instance, null), {}) : merge(
      sql_instance,
      {
        resource_index = join("_", [sql_instance_id])
      }
    )
    if try(sql_instance.instance, true)
  ])

  #
  # GCP Cloud SQL Databases
  #
  gcp_cloud_sql_database = flatten([
    for sql_instance_id, sql_instance in coalesce(try(local.cloud_sql.instance, null), {}) : [
      for sql_database_id, sql_database in coalesce(sql_instance.database, {}) : merge(
        sql_database,
        {
          instance       = coalesce(sql_database.instance, google_sql_database_instance.lz[sql_instance_id].name)
          resource_index = join("_", [sql_instance_id, sql_database_id])
        }
      )
    ]
  ])

  #
  # GCP Cloud SQL Users
  #
  gcp_cloud_sql_user = flatten([
    for sql_instance_id, sql_instance in coalesce(try(local.cloud_sql.instance, null), {}) : [
      for sql_user in coalesce(sql_instance.user, []) : merge(
        sql_user,
        {
          instance       = coalesce(sql_user.instance, google_sql_database_instance.lz[sql_instance_id].name)
          resource_index = join("_", [sql_instance_id, sql_user])
        }
      )
    ]
  ])

  #
  # GCP Cloud SQL SSL Certificates
  #
  gcp_cloud_sql_ssl_cert = flatten([
    for sql_instance_id, sql_instance in coalesce(try(local.cloud_sql.instance, null), {}) : [
      for ssl_cert in coalesce(sql_instance.ssl_cert, []) : merge(
        ssl_cert,
        {
          instance       = coalesce(ssl_cert.instance, google_sql_database_instance.lz[sql_instance_id].name)
          resource_index = join("_", [sql_instance_id, ssl_cert.common_name])
        }
      )
    ]
  ])

}
