#
# Validate GCP Compute Engine configurations
#

variable "validate" {
  description = "Configuration validation"
  type = object({
    enabled = bool
    #
    # Schema for individual validations
    #
    schema = object({
      gce_metadata_block_project_ssh_keys  = optional(bool, true)
      gce_default_service_account_disabled = optional(bool, true)
    })
  })
  #
  # Default validation configuration
  #
  default = {
    enabled = true
    schema = {
      gce_metadata_block_project_ssh_keys  = false # OSLogin required
      gce_default_service_account_disabled = true
    }
  }
}

locals {
  validation_header = "**** VALIDATION FAILURE: "
  validation_footer = " ****"
}

#
# Validate GCP Compute Engine configurations
#

resource "null_resource" "validate_gcp_compute_instance" {
  for_each = {
    for instance in local.gcp_compute_instance : instance.resource_index => instance
  }

  lifecycle {
    precondition {
      condition     = try(each.value.metadata["block-project-ssh-keys"], null) != null || !var.validate.schema.gce_metadata_block_project_ssh_keys
      error_message = format("%sinstance %s has no metadata configured to block project-wide SSH keys %s", local.validation_header, each.value.name, local.validation_footer)
    }

    precondition {
      condition     = try(each.value.service_account, null) != null || !var.validate.schema.gce_default_service_account_disabled
      error_message = format("%sinstance %s is using default service account %s", local.validation_header, each.value.name, local.validation_footer)
    }
  }
}
