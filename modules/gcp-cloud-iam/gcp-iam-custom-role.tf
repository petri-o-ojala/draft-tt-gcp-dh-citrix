#
# Custom IAM Roles
#

data "google_iam_role" "lz" {
  #
  # Roles that are referred from custom roles
  #
  for_each = toset(local.iam_predefined_roles)

  name = each.value
}

resource "google_project_iam_custom_role" "lz" {
  #
  # Customr IAM roles at project level
  #
  for_each = {
    for custom_role in local.custom_project_role : custom_role.resource_index => custom_role
  }

  role_id     = each.value.role_id
  title       = each.value.title
  project     = try(each.value.project, null)
  stage       = try(each.value.stage, null)
  description = try(each.value.description, null)
  permissions = each.value.permissions
}

resource "google_organization_iam_custom_role" "lz" {
  #
  # Customr IAM roles at organization level
  #
  for_each = {
    for custom_role in local.custom_organization_role : custom_role.resource_index => custom_role
  }

  role_id     = each.value.role_id
  org_id      = each.value.org_id
  title       = each.value.title
  stage       = try(each.value.stage, null)
  description = try(each.value.description, null)
  permissions = each.value.permissions
}
