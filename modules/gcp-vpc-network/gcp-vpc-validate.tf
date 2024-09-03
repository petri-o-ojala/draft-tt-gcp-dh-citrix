#
# Validate GCP Network configurations
#

variable "validate" {
  description = "Configuration validation"
  type = object({
    enabled = bool
    #
    # Schema for individual validations
    #
    schema = object({
      vpc_subnet_logging_enabled = optional(bool, false) # By default, VPC Flow logging is not expected
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
# Validate GCP Network configurations
#

resource "null_resource" "validate_gcp_vpc_subnet" {
  for_each = {
    for subnet in local.gcp_vpc_subnet : subnet.resource_index => subnet
  }

  lifecycle {
    precondition {
      condition     = try(each.value.log_config, null) != null || !var.validate.schema.vpc_subnet_logging_enabled
      error_message = format("%s Subnet %s (network %s) has no logging configured %s", local.validation_header, each.value.name, each.value.network, local.validation_footer)
    }
  }
}
