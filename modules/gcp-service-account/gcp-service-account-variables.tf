#
# GCP Deployments
#
# Each deployment can include required resources for the managed deployment pipeline, e.g.
# GCS storage for Terraform state and Service Accounts for pipeline access
#

variable "service_account" {
  description = "GCP Service Account configurations"
  type = map(
    object(
      {
        #
        # Service Accounts
        #
        account_id      = optional(string) # For new Service Accounts
        service_account = optional(string) # For existing Service Account IAM assignments
        project         = string
        display_name    = optional(string)
        description     = optional(string)
        disabled        = optional(bool)
        key = optional(object({
          rotation_days    = optional(number)
          key_algorithm    = optional(string)
          public_key_type  = optional(string)
          private_key_type = optional(string)
          public_key_data  = optional(string)
        }))
        service_account_iam = optional(list(object({
          role    = optional(string)
          member  = optional(list(string))
          project = optional(string)
          condition = optional(object({
            expression  = string
            title       = string
            description = optional(string)
          }))
        })))
        iam = optional(list(object({
          # 
          # When using, define the target resource for this IAM assignment
          #
          project_id          = optional(string)
          storage_bucket_name = optional(string)
          folder_id           = optional(string)
          org_id              = optional(string)
          billing_account_id  = optional(string)
          service_account_id  = optional(string)
          managed_zone_name   = optional(string)
          project             = optional(string)
          subnetwork          = optional(string)
          role                = optional(list(string))
          policy_data         = optional(string)
          condition = optional(object({
            expression  = string
            title       = string
            description = optional(string)
          }))
        })))
      }
    )
  )
  default = {}
}

variable "service_account_json_configuration_file" {
  description = "JSON configuration file for service accounts"
  type        = string
  default     = "gcp-service-account.json"
}

variable "service_account_yaml_configuration_file" {
  description = "YAML configuration file for service accounts"
  type        = string
  default     = "gcp-service-account.yaml"
}

locals {
  #
  # Support for JSON, YAML and variable configuration
  #
  service_account_json_configuration = fileexists("${path.root}/${var.service_account_json_configuration_file}") ? jsondecode(file("${path.root}/${var.service_account_json_configuration_file}")) : {}
  service_account_yaml_configuration = fileexists("${path.root}/${var.service_account_yaml_configuration_file}") ? yamldecode(file("${path.root}/${var.service_account_yaml_configuration_file}")) : {}

  service_account = merge(
    var.service_account,
    try(local.service_account_json_configuration.project, {}),
    try(local.service_account_yaml_configuration.project, {}),
  )

  #
  # Service accounts
  #
  gcp_service_account = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : merge(
      service_account,
      {
        service_account_name = service_account_name
        resource_index       = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
      }
    )
  ])

  #
  # Service Account IAM assignments
  #
  service_account_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.service_account_iam, null), []) : [
        for member in coalesce(try(iam.member, null), []) : {
          member = element(concat(
            [
              # Members that are not referring to ID from other resources
              for m in [member] : m
              if !startswith(m, "Reference:")
            ],
            [
              # Members that are using Workload Identity Pool ID
              for m in [member] : "principalSet://iam.googleapis.com/${lookup(lookup(local.gcp_iam_workload_identity_pool, split(":", m)[2], null), "id", "workload-identity-pool-not-found")}${split(":", m)[3]}"
              if startswith(m, "Reference:workloadIdentityPool:")
            ],
            [
              # Members that are using Workload Identity Pool ID
              for m in [member] : "principalSet://iam.googleapis.com/${lookup(lookup(local.gcp_iam_workload_identity_pool, split(":", m)[2], null), "name", "workload-identity-pool-not-found")}${split(":", m)[3]}"
              if startswith(m, "Reference:workloadIdentityPoolName:")
            ]
          ), 0) # We will only use one (first) member of the above, this is just to make the code more readable above
          role                     = iam.role
          condition                = iam.condition
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, iam.role, member])
        }
      ]
    ]
  ])

  #
  # Service Account IAM assignments to Service Account
  #
  service_account_target_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          service_account_id       = iam.service_account_id
          role                     = role
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.service_account_id, role])
        }
      ]
      if iam.service_account_id != null
    ]
  ])


  #
  # Service Account IAM assignments to Billing Account
  #
  service_account_billing_account_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          billing_account_id       = iam.billing_account_id
          role                     = role
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.billing_account_id, role])
        }
      ]
      if iam.billing_account_id != null
    ]
  ])

  #
  # Service Account IAM assignments to Organization ID
  #
  service_account_organization_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          org_id                   = iam.org_id
          role                     = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.org_id, role])
        }
      ]
      if iam.org_id != null
    ]
  ])

  #
  # Service Account IAM assignments to Folder ID
  #
  service_account_folder_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          folder_id                = iam.folder_id
          role                     = role
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.folder_id, role])
        }
      ]
      if iam.folder_id != null
    ]
  ])

  #
  # Service Account IAM assignments to projects
  #
  service_account_project_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          project_id               = iam.project_id
          role                     = role
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.project_id, role])
        }
      ]
      if iam.project_id != null
    ]
  ])

  #
  # GCS Storage Bucket IAM assignments
  #
  storage_bucket_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          storage_bucket_name      = iam.storage_bucket_name
          role                     = role
          policy_data              = iam.policy_data
          condition                = iam.condition
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.storage_bucket_name, role])
        }
      ]
      if iam.storage_bucket_name != null
    ]
  ])

  #
  # Cloud DNS Managed Zone IAM assignments
  #
  dns_managed_zone_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          managed_zone_name        = iam.managed_zone_name
          role                     = role
          project                  = iam.project
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.managed_zone_name, role])
        }
      ]
      if iam.managed_zone_name != null
    ]
  ])

  #
  # VPC Subnetwork IAM assignments
  #
  service_account_subnetwork_iam = flatten([
    for service_account_name, service_account in coalesce(try(local.service_account, null), {}) : [
      for iam in coalesce(try(service_account.iam, null), []) : [
        for role in coalesce(try(iam.role, null), []) : {
          subnetwork               = iam.subnetwork
          role                     = role
          service_account          = service_account.service_account
          service_account_resource = join(":", [service_account_name, coalesce(service_account.account_id, service_account.service_account)])
          resource_index           = join("_", [service_account_name, coalesce(service_account.account_id, service_account.service_account), iam.subnetwork, role])
        }
      ]
      if iam.subnetwork != null
    ]
  ])
}
