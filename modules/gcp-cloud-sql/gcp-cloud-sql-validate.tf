#
# Validate GCP Cloud SQL configurations
#

variable "validate" {
  description = "Configuration validation"
  type = object({
    enabled = bool
    #
    # Schema for individual validations
    #
    schema = object({
      cloud_sql_require_ssl = optional(bool, true)
    })
  })
  #
  # Default validation configuration
  #
  default = {
    enabled = true
    schema  = {}
  }
}

locals {
  validation_header = "**** VALIDATION FAILURE: "
  validation_footer = " ****"
}

#
# Validate GCP Cloud SQL configurations
#

resource "null_resource" "validate_gcp_cloud_sql_instance" {
  for_each = {
    for csql in local.gcp_cloud_sql_instance : csql.resource_index => csql
  }

  lifecycle {
    precondition {
      condition     = (try(each.value.settings.ip_configuration.require_ssl, null) == null || try(each.value.settings.ip_configuration.ssl_mode, null) == null) || !var.validate.schema.cloud_sql_require_ssl
      error_message = format("%sCloud SQL database instance %s must require SSL %s", local.validation_header, each.value.name, local.validation_footer)
    }
  }
}
