#
# Validate GCP Load Balancer configurations
#

variable "validate" {
  description = "Configuration validation"
  type = object({
    enabled = bool
    #
    # Schema for individual validations
    #
    schema = object({
      gclb_ssl_policy_tls_version = optional(bool, true)
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
# Validate GCP Load Balancer configurations
#

resource "null_resource" "validate_gcp_lb_ssl_policy" {
  for_each = {
    for ssl_policy in local.gcp_lb_ssl_policy : ssl_policy.resource_index => ssl_policy
  }

  lifecycle {
    precondition {
      condition     = !contains(["TLS_1_0", "TLS_1_1"], try(each.value.min_tls_version, "TLS_1_0")) || !var.validate.schema.gclb_ssl_policy_tls_version
      error_message = format("%sSSL policy %s is configured with minimum TLS version lower than 1.2 %s", local.validation_header, each.value.name, local.validation_footer)
    }
  }
}
