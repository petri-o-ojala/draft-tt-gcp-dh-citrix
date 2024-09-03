<!-- BEGIN_TF_DOCS -->

Cloud Logging module

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_billing_account_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/billing_account_iam_member) | resource |
| [google_compute_subnetwork_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork_iam_member) | resource |
| [google_dns_managed_zone_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_managed_zone_iam_member) | resource |
| [google_folder_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_organization_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |
| [google_project_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.sa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_key.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket_iam_member.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [time_rotating.lz](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/rotating) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_reference"></a> [reference](#input\_reference) | GCP Resource references | <pre>object({<br>    gcp_iam_workload_identity_pool   = optional(map(any))<br>    gcp_organization_iam_custom_role = optional(map(any))<br>  })</pre> | `{}` | no |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | GCP Service Account configurations | <pre>map(<br>    object(<br>      {<br>        #<br>        # Service Accounts<br>        #<br>        account_id      = optional(string) # For new Service Accounts<br>        service_account = optional(string) # For existing Service Account IAM assignments<br>        project         = string<br>        display_name    = optional(string)<br>        description     = optional(string)<br>        disabled        = optional(bool)<br>        key = optional(object({<br>          rotation_days    = optional(number)<br>          key_algorithm    = optional(string)<br>          public_key_type  = optional(string)<br>          private_key_type = optional(string)<br>          public_key_data  = optional(string)<br>        }))<br>        service_account_iam = optional(list(object({<br>          role    = optional(string)<br>          member  = optional(list(string))<br>          project = optional(string)<br>          condition = optional(object({<br>            expression  = string<br>            title       = string<br>            description = optional(string)<br>          }))<br>        })))<br>        iam = optional(list(object({<br>          # <br>          # When using, define the target resource for this IAM assignment<br>          #<br>          project_id          = optional(string)<br>          storage_bucket_name = optional(string)<br>          folder_id           = optional(string)<br>          org_id              = optional(string)<br>          billing_account_id  = optional(string)<br>          service_account_id  = optional(string)<br>          managed_zone_name   = optional(string)<br>          project             = optional(string)<br>          subnetwork          = optional(string)<br>          role                = optional(list(string))<br>          policy_data         = optional(string)<br>          condition = optional(object({<br>            expression  = string<br>            title       = string<br>            description = optional(string)<br>          }))<br>        })))<br>      }<br>    )<br>  )</pre> | `{}` | no |
| <a name="input_service_account_json_configuration_file"></a> [service\_account\_json\_configuration\_file](#input\_service\_account\_json\_configuration\_file) | JSON configuration file for service accounts | `string` | `"gcp-service-account.json"` | no |
| <a name="input_service_account_yaml_configuration_file"></a> [service\_account\_yaml\_configuration\_file](#input\_service\_account\_yaml\_configuration\_file) | YAML configuration file for service accounts | `string` | `"gcp-service-account.yaml"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_service_account"></a> [gcp\_service\_account](#output\_gcp\_service\_account) | Service Account resources |
<!-- END_TF_DOCS -->