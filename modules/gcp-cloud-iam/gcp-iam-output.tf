#
# Terraform module outputs
#

output "gcp_iam_workload_identity_pool" {
  description = "GCP Workload Identity Pool resources"
  value = {
    for pool in local.gcp_workload_identity_pool : pool.configuration_pool_id => google_iam_workload_identity_pool.lz[pool.resource_index]
  }
}

output "gcp_iam_workload_identity_pool_provider" {
  description = "GCP Workload Identity Pool Provider resources"
  value = {
    for provider in local.gcp_workload_identity_pool_provider : provider.configuration_provider_id => google_iam_workload_identity_pool_provider.lz[provider.resource_index]
  }
}

output "gcp_organization_iam_custom_role" {
  description = "GCP Organization Custom IAM Policy resources"
  value = {
    for custom_role in local.custom_organization_role : custom_role.configuration_custom_role_id => google_organization_iam_custom_role.lz[custom_role.resource_index]
  }
}

output "gcp_project_iam_custom_role" {
  description = "GCP Project Custom IAM Policy resources"
  value = {
    for custom_role in local.custom_project_role : custom_role.configuration_custom_role_id => google_project_iam_custom_role.lz[custom_role.resource_index]
  }
}
