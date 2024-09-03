<!-- BEGIN_TF_DOCS -->

GCP Certificate Manager

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
| [google_certificate_manager_certificate.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate) | resource |
| [google_certificate_manager_certificate_map.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map) | resource |
| [google_certificate_manager_certificate_map_entry.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_certificate_map_entry) | resource |
| [google_certificate_manager_dns_authorization.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/certificate_manager_dns_authorization) | resource |
| [google_dns_record_set.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_manager"></a> [certificate\_manager](#input\_certificate\_manager) | GCP Certificate Manager configurations | <pre>object(<br>    {<br>      certificate = optional(map(object({<br>        name        = string<br>        description = optional(string)<br>        project     = optional(string)<br>        location    = optional(string)<br>        labels      = optional(map(string))<br>        scope       = optional(string)<br>        self_managed = optional(object({<br>          pem_certificate = optional(string)<br>          pem_private_key = optional(string)<br>        }))<br>        managed = optional(object({<br>          domains            = optional(list(string))<br>          dns_authorizations = optional(list(string))<br>          issuance_config    = optional(string)<br>        }))<br>      })))<br>      certificate_map = optional(map(object({<br>        name        = string<br>        description = optional(string)<br>        labels      = optional(map(string))<br>        project     = optional(string)<br>        entry = optional(list(object({<br>          name         = string<br>          certificates = list(string)<br>          description  = optional(string)<br>          labels       = optional(map(string))<br>          hostname     = optional(string)<br>          matcher      = optional(string)<br>          project      = optional(string)<br>        })))<br>      })))<br>      dns_authorization = optional(map(object({<br>        domain      = string<br>        name        = string<br>        description = optional(string)<br>        type        = optional(string)<br>        labels      = optional(map(string))<br>        location    = optional(string)<br>        project     = optional(string)<br>        managed_zone = optional(object({<br>          project = string<br>          name    = string<br>          ttl     = optional(number)<br>        }))<br>      })))<br>    }<br>  )</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_certificate_manager_certificate"></a> [gcp\_certificate\_manager\_certificate](#output\_gcp\_certificate\_manager\_certificate) | GCP Certificate Manager Certificate resources |
| <a name="output_gcp_certificate_manager_certificate_map"></a> [gcp\_certificate\_manager\_certificate\_map](#output\_gcp\_certificate\_manager\_certificate\_map) | GCP Certificate Manager Certificate Map resources |
| <a name="output_gcp_certificate_manager_dns_authorization"></a> [gcp\_certificate\_manager\_dns\_authorization](#output\_gcp\_certificate\_manager\_dns\_authorization) | GCP Certificate Manager DNS Authorization resources |
<!-- END_TF_DOCS -->