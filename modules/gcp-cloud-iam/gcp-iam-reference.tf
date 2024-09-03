#
# Input references to other resources
#

variable "reference" {
  description = "GCP Resource references"
  type = object({
    gcp_organization_iam_custom_role = optional(map(any))
    gcp_project_iam_custom_role      = optional(map(any))
  })
  default = {}
}

locals {
  gcp_organization_iam_custom_role = coalesce(var.reference.gcp_organization_iam_custom_role, {})
  gcp_project_iam_custom_role      = coalesce(var.reference.gcp_project_iam_custom_role, {})

  gcp_custom_roles = merge(
    # References roles
    local.gcp_organization_iam_custom_role,
    local.gcp_project_iam_custom_role,
    # Created roles
    google_project_iam_custom_role.lz,
    google_organization_iam_custom_role.lz
  )
}
