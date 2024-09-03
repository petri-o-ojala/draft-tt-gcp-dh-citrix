#
# Input references to other resources
#

variable "reference" {
  description = "GCP Resource references"
  type = object({
    gcp_forwarding_rule_target  = optional(map(any))
    gcp_compute_forwarding_rule = optional(map(any))
  })
  default = {}
}

locals {
  gcp_forwarding_rule_target  = coalesce(var.reference.gcp_forwarding_rule_target, {})
  gcp_compute_forwarding_rule = coalesce(var.reference.gcp_compute_forwarding_rule, {})
}
