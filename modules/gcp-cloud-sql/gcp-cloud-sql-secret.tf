#
# Cloud SQL Secret Manager passwords
#

locals {
  google_secret_manager_secret         = google_secret_manager_secret.cloud_sql
  google_secret_manager_secret_version = google_secret_manager_secret_version.cloud_sql
}

resource "google_secret_manager_secret" "cloud_sql" {
  for_each = {
    for secret in local.gcp_secret_manager_secret : secret.resource_index => secret
  }

  secret_id = each.value.secret_id

  replication {
    dynamic "auto" {
      for_each = try(each.value.replication.auto, null) == null ? [] : [1]

      content {
        dynamic "customer_managed_encryption" {
          for_each = try(each.value.replication.auto.customer_managed_encryption, null) == null ? [] : [1]

          content {
            kms_key_name = each.value.replication.auto.customer_managed_encryption.kms_key_name
          }
        }
      }
    }

    dynamic "user_managed" {
      for_each = try(each.value.replication.user_managed, null) == null ? [] : [1]

      content {
        dynamic "replicas" {
          for_each = coalesce(each.value.replication.user_managed.replicas, [])

          content {
            location = replicas.value.location

            dynamic "customer_managed_encryption" {
              for_each = try(replicas.value.customer_managed_encryption, null) == null ? [] : [1]

              content {
                kms_key_name = replicas.value.auto.customer_managed_encryption.kms_key_name
              }
            }
          }
        }
      }
    }
  }

  labels          = each.value.labels
  annotations     = each.value.annotations
  version_aliases = each.value.version_aliases

  dynamic "topics" {
    for_each = coalesce(each.value.topics, [])

    content {
      name = topics.value.name
    }
  }

  expire_time = each.value.expire_time
  ttl         = each.value.ttl

  dynamic "rotation" {
    for_each = try(each.value.rotation, null) == null ? [] : [1]

    content {
      next_rotation_time = eeach.value.rotation.next_rotation_time
      rotation_period    = eeach.value.rotation.rotation_period
    }
  }

  project = each.value.project
}

resource "google_secret_manager_secret_version" "cloud_sql" {
  for_each = {
    for secret in local.gcp_secret_manager_secret : secret.resource_index => secret
    if secret.random_password != null || secret.secret_data != null
  }

  secret      = google_secret_manager_secret.cloud_sql[each.key].id
  secret_data = coalesce(each.value.secret_data, random_password.cloud_sql[each.key].result)

  enabled               = try(each.value.secret_version.enabled, null)
  deletion_policy       = try(each.value.secret_version.deletion_policy, null)
  is_secret_data_base64 = try(each.value.secret_version.is_secret_data_base64, null)
}

resource "random_password" "cloud_sql" {
  for_each = {
    for secret in local.gcp_secret_manager_secret : secret.resource_index => secret
    if secret.random_password != null
  }

  ## Need to match the password policy
  length           = each.value.random_password.length
  upper            = each.value.random_password.upper
  min_upper        = each.value.random_password.min_upper
  lower            = each.value.random_password.lower
  min_lower        = each.value.random_password.min_lower
  numeric          = each.value.random_password.numeric
  min_numeric      = each.value.random_password.min_numeric
  special          = each.value.random_password.special
  override_special = each.value.random_password.override_special
  min_special      = each.value.random_password.min_special

  lifecycle {
    # To avoid replacement e.g. with import
    ignore_changes = [
      length,
      min_lower,
      min_numeric,
      min_special,
      min_upper,
      override_special
    ]
  }
}
