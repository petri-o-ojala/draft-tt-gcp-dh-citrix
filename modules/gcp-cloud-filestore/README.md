<!-- BEGIN_TF_DOCS -->

GCP Filestore

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
| [google_dns_record_set.memorystore_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_filestore_backup.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_backup) | resource |
| [google_filestore_instance.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_instance) | resource |
| [google_filestore_snapshot.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_snapshot) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_filestore"></a> [filestore](#input\_filestore) | GCP Filestore configurations | <pre>object({<br>    instance = optional(map(object({<br>      name         = string<br>      tier         = string<br>      description  = optional(string)<br>      labels       = optional(map(string))<br>      kms_key_name = optional(string)<br>      location     = optional(string)<br>      project      = optional(string)<br>      file_shares = list(object({<br>        name          = string<br>        capacity_gb   = string<br>        source_backup = optional(string)<br>        nfs_export_options = optional(list(object({<br>          ip_ranges   = optional(list(string))<br>          access_mode = optional(string)<br>          squash_mode = optional(string)<br>          anon_uid    = optional(number)<br>          anon_gid    = optional(number)<br>        })))<br>      }))<br>      networks = list(object({<br>        network           = string<br>        modes             = list(string)<br>        reserved_ip_range = optional(string)<br>        connect_mode      = optional(string)<br>      }))<br>      dns = optional(list(object({<br>        name            = string<br>        type            = optional(string, "A")<br>        ttl             = optional(number, 300)<br>        managed_zone    = string<br>        project         = optional(string)<br>        rr_data_address = optional(bool)<br>        rr_data         = optional(list(string))<br>      })))<br>    })))<br>    backup = optional(map(object({<br>      name              = string<br>      source_instance   = string<br>      source_file_share = string<br>      location          = string<br>      description       = optional(string)<br>      labels            = optional(map(string))<br>      project           = optional(string)<br>    })))<br>    snapshot = optional(map(object({<br>      name        = string<br>      location    = string<br>      instance    = string<br>      description = optional(string)<br>      labels      = optional(map(string))<br>      project     = optional(string)<br>    })))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_filestore_backup"></a> [gcp\_filestore\_backup](#output\_gcp\_filestore\_backup) | GCP Filestore backup resources |
| <a name="output_gcp_filestore_instance"></a> [gcp\_filestore\_instance](#output\_gcp\_filestore\_instance) | GCP Filestore instance resources |
| <a name="output_gcp_filestore_snapshot"></a> [gcp\_filestore\_snapshot](#output\_gcp\_filestore\_snapshot) | GCP Filestore snapshot resources |
<!-- END_TF_DOCS -->