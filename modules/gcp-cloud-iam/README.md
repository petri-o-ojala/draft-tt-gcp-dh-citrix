<!-- BEGIN_TF_DOCS -->

GCP Cloud IAM

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_folder_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_iam_deny_policy.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_deny_policy) | resource |
| [google_iam_workload_identity_pool.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |
| [google_organization_iam_audit_config.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_audit_config) | resource |
| [google_organization_iam_custom_role.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_custom_role) | resource |
| [google_organization_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_custom_role.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_pubsub_subscription_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [google_service_account_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_storage_bucket_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_iam_role.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_iam"></a> [cloud\_iam](#input\_cloud\_iam) | Cloud IAM Configurations | <pre>object({<br>    audit_config = optional(object({<br>      organization = optional(map(object({<br>        org_id  = string<br>        service = string<br>        audit_log_config = list(object({<br>          log_type         = string<br>          exempted_members = optional(list(string))<br>        }))<br>      })))<br>    }))<br>    binding = optional(map(list(object({<br>      # Binding target resource<br>      project_id           = optional(string)<br>      service_account_id   = optional(string)<br>      org_id               = optional(string)<br>      folder_id            = optional(string)<br>      storage_bucket       = optional(string)<br>      pub_sub_topic        = optional(string)<br>      pub_sub_subscription = optional(string)<br>      #<br>      project = optional(string) # If used by the IAM binding itself to define the resource project<br>      #<br>      role   = list(string)<br>      member = optional(list(string))<br>    }))))<br>    custom_role = optional(map(object({<br>      role_id               = string<br>      title                 = string<br>      project               = optional(list(string))<br>      org_id                = optional(string)<br>      stage                 = optional(string)<br>      description           = optional(string)<br>      permission            = optional(list(string))<br>      predefined_role       = optional(list(string))<br>      predefined_role_regex = optional(map(string))<br>    })))<br>    workload_identity = optional(object({<br>      pool = optional(map(object({<br>        workload_identity_pool_id = string<br>        display_name              = optional(string)<br>        description               = optional(string)<br>        disabled                  = optional(bool)<br>        project                   = optional(string)<br>      })))<br>      pool_provider = optional(map(object({<br>        workload_identity_pool_id          = string<br>        workload_identity_pool_provider_id = string<br>        display_name                       = optional(string)<br>        description                        = optional(string)<br>        disabled                           = optional(bool)<br>        project                            = optional(string)<br>        attribute_mapping                  = optional(map(string))<br>        attribute_condition                = optional(string)<br>        aws = optional(object({<br>          account_id = string<br>        }))<br>        oidc = optional(object({<br>          allowed_audiences = optional(list(string))<br>          issuer_uri        = string<br>          jwks_json         = optional(string)<br>        }))<br>        saml = optional(object({<br>          idp_metadata_xml = string<br>        }))<br>      })))<br>    }))<br>    iam_policy = optional(object({<br>      deny = optional(map(object({<br>        name    = string<br>        parent  = string<br>        project = optional(string)<br>        rules = optional(list(object({<br>          description = optional(string)<br>          deny_rule = optional(object({<br>            denied_principals     = optional(list(string))<br>            exception_principals  = optional(list(string))<br>            exception_permissions = optional(list(string))<br>            denial_condition = optional(object({<br>              expression  = string<br>              title       = optional(string)<br>              description = optional(string)<br>              location    = optional(string)<br>            }))<br>          }))<br>        })))<br>      })))<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_reference"></a> [reference](#input\_reference) | GCP Resource references | <pre>object({<br>    gcp_organization_iam_custom_role = optional(map(any))<br>    gcp_project_iam_custom_role      = optional(map(any))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_iam_workload_identity_pool"></a> [gcp\_iam\_workload\_identity\_pool](#output\_gcp\_iam\_workload\_identity\_pool) | GCP Workload Identity Pool resources |
| <a name="output_gcp_iam_workload_identity_pool_provider"></a> [gcp\_iam\_workload\_identity\_pool\_provider](#output\_gcp\_iam\_workload\_identity\_pool\_provider) | GCP Workload Identity Pool Provider resources |
| <a name="output_gcp_organization_iam_custom_role"></a> [gcp\_organization\_iam\_custom\_role](#output\_gcp\_organization\_iam\_custom\_role) | GCP Organization Custom IAM Policy resources |
| <a name="output_gcp_project_iam_custom_role"></a> [gcp\_project\_iam\_custom\_role](#output\_gcp\_project\_iam\_custom\_role) | GCP Project Custom IAM Policy resources |
<!-- END_TF_DOCS -->