#
# Input references to other resources
#

variable "reference" {
  description = "GCP Resource references"
  type = object({
    gcp_iam_workload_identity_pool   = optional(map(any))
    gcp_organization_iam_custom_role = optional(map(any))
  })
  default = {}
}

locals {
  gcp_iam_workload_identity_pool   = coalesce(var.reference.gcp_iam_workload_identity_pool, {})
  gcp_organization_iam_custom_role = coalesce(var.reference.gcp_organization_iam_custom_role, {})

  gcp_custom_roles = local.gcp_organization_iam_custom_role
}
