#
# GCP Cloud IAM
#

variable "cloud_iam" {
  description = "Cloud IAM Configurations"
  type = object({
    audit_config = optional(object({
      organization = optional(map(object({
        org_id  = string
        service = string
        audit_log_config = list(object({
          log_type         = string
          exempted_members = optional(list(string))
        }))
      })))
    }))
    binding = optional(map(list(object({
      # Binding target resource
      project_id           = optional(string)
      service_account_id   = optional(string)
      org_id               = optional(string)
      folder_id            = optional(string)
      storage_bucket       = optional(string)
      pub_sub_topic        = optional(string)
      pub_sub_subscription = optional(string)
      #
      project = optional(string) # If used by the IAM binding itself to define the resource project
      #
      role   = list(string)
      member = optional(list(string))
    }))))
    custom_role = optional(map(object({
      role_id               = string
      title                 = string
      project               = optional(list(string))
      org_id                = optional(string)
      stage                 = optional(string)
      description           = optional(string)
      permission            = optional(list(string))
      predefined_role       = optional(list(string))
      predefined_role_regex = optional(map(string))
    })))
    workload_identity = optional(object({
      pool = optional(map(object({
        workload_identity_pool_id = string
        display_name              = optional(string)
        description               = optional(string)
        disabled                  = optional(bool)
        project                   = optional(string)
      })))
      pool_provider = optional(map(object({
        workload_identity_pool_id          = string
        workload_identity_pool_provider_id = string
        display_name                       = optional(string)
        description                        = optional(string)
        disabled                           = optional(bool)
        project                            = optional(string)
        attribute_mapping                  = optional(map(string))
        attribute_condition                = optional(string)
        aws = optional(object({
          account_id = string
        }))
        oidc = optional(object({
          allowed_audiences = optional(list(string))
          issuer_uri        = string
          jwks_json         = optional(string)
        }))
        saml = optional(object({
          idp_metadata_xml = string
        }))
      })))
    }))
    iam_policy = optional(object({
      deny = optional(map(object({
        name    = string
        parent  = string
        project = optional(string)
        rules = optional(list(object({
          description = optional(string)
          deny_rule = optional(object({
            denied_principals     = optional(list(string))
            exception_principals  = optional(list(string))
            exception_permissions = optional(list(string))
            denial_condition = optional(object({
              expression  = string
              title       = optional(string)
              description = optional(string)
              location    = optional(string)
            }))
          }))
        })))
      })))
    }))
  })
  default = {}
}

locals {
  cloud_iam = var.cloud_iam

  audit_config      = try(local.cloud_iam.audit_config, {})
  workload_identity = try(local.cloud_iam.workload_identity, {})
  iam_policy        = try(local.cloud_iam.iam_policy, {})
  iam_custom_role   = coalesce(try(local.cloud_iam.custom_role, {}), {})
  iam_binding       = coalesce(try(local.cloud_iam.binding, {}), {})

  #
  # GCP Workload Identity Pools
  #
  gcp_workload_identity_pool = flatten([
    for pool_id, pool in coalesce(try(local.workload_identity.pool, null), {}) : merge(
      pool,
      {
        configuration_pool_id = pool_id
        resource_index        = join("_", [pool_id])
      }
    )
  ])

  #
  # GCP Workload Identity Pool Providers
  #
  gcp_workload_identity_pool_provider = flatten([
    for provider_id, provider in coalesce(try(local.workload_identity.pool_provider, null), {}) : merge(
      provider,
      {
        configuration_provider_id = provider_id
        resource_index            = join("_", [provider_id])
      }
    )
  ])

  #
  # GCP IAM Organization Audit Configuration
  #

  gcp_iam_organization_audit_config = flatten([
    for config_id, config in coalesce(try(local.audit_config.organization, null), {}) : merge(
      config,
      {
        resource_index = join("_", [config_id])
      }
    )
  ])

  #
  # GCP IAM Deny Policies
  #
  gcp_iam_deny_policy = flatten([
    for policy_id, policy in coalesce(try(local.iam_policy.deny, null), {}) : merge(
      policy,
      {
        resource_index = join("_", [policy_id])
      }
    )
  ])

  #
  # Custom IAM roles
  #

  #
  # Pre-defined IAM roles that are used by the custom roles
  #
  iam_predefined_roles = distinct(flatten(concat(
    [
      for custom_role_name, custom_role in local.iam_custom_role : coalesce(custom_role.predefined_role, [])
    ],
    flatten([
      for custom_role_name, custom_role in local.iam_custom_role : [
        for role, role_regex in coalesce(custom_role.predefined_role_regex, {}) : role
      ]
      ]
    ))
  ))

  #
  # Custom roles at project level
  #
  custom_project_role = flatten([
    for custom_role_id, custom_role in local.iam_custom_role : [
      for project in coalesce(custom_role.project, []) :
      {
        configuration_custom_role_id = custom_role_id
        role_id                      = custom_role.role_id
        title                        = custom_role.title
        project                      = project
        stage                        = try(custom_role.stage, null)
        description                  = try(custom_role.description, null)
        permissions = distinct(compact(concat(
          coalesce(custom_role.permission, []),
          flatten([
            for role in coalesce(custom_role.predefined_role, []) : data.google_iam_role.lz[role].included_permissions
          ]),
          flatten([
            for role, role_regex in coalesce(custom_role.predefined_role_regex, {}) : [
              for permission in data.google_iam_role.lz[role].included_permissions : length(regexall(role_regex, permission)) > 0 ? permission : null
            ]
          ])
        )))
        resource_index = join("_", [custom_role_id, project])
      }
    ]
    if try(custom_role.project, null) != null
  ])

  #
  # Custom roles at organization level
  #
  custom_organization_role = flatten([
    for custom_role_id, custom_role in local.iam_custom_role :
    {
      configuration_custom_role_id = custom_role_id
      role_id                      = custom_role.role_id
      title                        = custom_role.title
      org_id                       = custom_role.org_id
      stage                        = try(custom_role.stage, null)
      description                  = try(custom_role.description, null)
      permissions = distinct(compact(concat(
        coalesce(custom_role.permission, []),
        flatten([
          for role in coalesce(custom_role.predefined_role, []) : data.google_iam_role.lz[role].included_permissions
        ]),
        flatten([
          for role, role_regex in coalesce(custom_role.predefined_role_regex, {}) : [
            for permission in data.google_iam_role.lz[role].included_permissions : length(regexall(role_regex, permission)) > 0 ? permission : null
          ]
        ])
      )))
      resource_index = join("_", [custom_role_id, custom_role.org_id])
    }
    if try(custom_role.org_id, null) != null
  ])

  #
  # Service Account IAM assignments to projects
  #

  gcp_iam_binding_organization = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            org_id         = iam.org_id
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.org_id != null
      ]
    ]
  ])

  gcp_iam_binding_folder = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            folder_id      = iam.folder_id
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.folder_id != null
      ]
    ]
  ])

  gcp_iam_binding_project = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            project_id     = iam.project_id
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.project_id != null
      ]
    ]
  ])

  gcp_iam_binding_service_account = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            service_account_id = iam.service_account_id
            role               = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member             = member
            resource_index     = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.service_account_id != null
      ]
    ]
  ])

  gcp_iam_binding_storage_bucket = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            bucket         = iam.storage_bucket
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.storage_bucket != null
      ]
    ]
  ])

  gcp_pubsub_topic_iam_member = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            topic          = iam.pub_sub_topic
            project        = iam.project
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.pub_sub_topic != null
      ]
    ]
  ])

  gcp_pubsub_subscription_iam_member = flatten([
    for iam_binding_name, iam_binding in coalesce(try(local.iam_binding, null), {}) : [
      for iam in coalesce(iam_binding, []) : [
        for role in coalesce(try(iam.role, null), []) : [
          for member in coalesce(try(iam.member, null), []) : {
            subscription   = iam.pub_sub_subscription
            project        = iam.project
            role           = lookup(local.gcp_custom_roles, role, null) == null ? role : local.gcp_custom_roles[role].id
            member         = member
            resource_index = join("_", [iam_binding_name, role, member])
          }
        ]
        if iam.pub_sub_subscription != null
      ]
    ]
  ])
}
