<!-- BEGIN_TF_DOCS -->

GCP Private Service Connect/Access

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.10.0 |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_forwarding_rule.vpc](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_forwarding_rule) | resource |
| [google-beta_google_compute_global_forwarding_rule.vpc](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_global_forwarding_rule) | resource |
| [google_compute_address.psc](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_global_address.psa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network_endpoint_group.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoint_group) | resource |
| [google_compute_network_endpoints.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network_endpoints) | resource |
| [google_compute_region_network_endpoint.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint) | resource |
| [google_compute_region_network_endpoint_group.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_network_endpoint_group) | resource |
| [google_compute_service_attachment.lz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_service_attachment) | resource |
| [google_dns_record_set.gclz](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dns_record_set) | resource |
| [google_service_networking_connection.psa](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_neg"></a> [neg](#input\_neg) | GCP Network Endpoint Group configurations | <pre>object({<br>    network_endpoint_group = optional(map(object({<br>      name                  = string<br>      network               = string<br>      region                = optional(string)<br>      description           = optional(string)<br>      network_endpoint_type = optional(string)<br>      psc_target_service    = optional(string)<br>      subnetwork            = optional(string)<br>      default_port          = optional(number)<br>      zone                  = optional(string)<br>      project               = optional(string)<br>      cloud_run = optional(object({<br>        service  = optional(string)<br>        tag      = optional(string)<br>        url_mask = optional(string)<br>      }))<br>      app_engine = optional(object({<br>        service  = optional(string)<br>        version  = optional(string)<br>        url_mask = optional(string)<br>      }))<br>      cloud_function = optional(object({<br>        function = optional(string)<br>        url_mask = optional(string)<br>      }))<br>      serverless_deployment = optional(object({<br>        platform = optional(string)<br>        resource = optional(string)<br>        version  = optional(string)<br>        url_mask = optional(string)<br>      }))<br>    })))<br>    network_endpoint = optional(map(object({<br>      network_endpoint_group = string<br>      region                 = optional(string)<br>      zone                   = optional(string)<br>      project                = optional(string)<br>      ip_address             = optional(string)<br>      port                   = optional(number)<br>      fqdn                   = optional(string)<br>      network_endpoints = optional(list(object({<br>        instance   = optional(string)<br>        port       = optional(number)<br>        ip_address = string<br>      })))<br>    })))<br>  })</pre> | `{}` | no |
| <a name="input_psa"></a> [psa](#input\_psa) | GCP Private Service Access configurations | <pre>object({<br>    service = optional(map(object({<br>      network = string<br>      address = optional(list(object({<br>        name          = string<br>        description   = optional(string)<br>        region        = optional(string)<br>        project       = optional(string)<br>        address       = optional(string)<br>        address_type  = optional(string, "INTERNAL")<br>        purpose       = optional(string, "VPC_PEERING")<br>        prefix_length = optional(number)<br>        ip_version    = optional(string)<br>      })))<br>    })))<br>  })</pre> | `{}` | no |
| <a name="input_psc"></a> [psc](#input\_psc) | GCP Private Service Connect configurations | <pre>object({<br>    forwarding_rule = optional(map(object({<br>      name                    = string<br>      project                 = optional(string)<br>      is_mirroring_collector  = optional(bool)<br>      description             = optional(string)<br>      ip_address              = optional(string)<br>      ip_protocol             = optional(string)<br>      backend_service         = optional(string)<br>      load_balancing_scheme   = optional(string)<br>      network                 = optional(string)<br>      port_range              = optional(string)<br>      ports                   = optional(list(string))<br>      subnetwork              = optional(string)<br>      target                  = optional(string)<br>      allow_global_access     = optional(bool)<br>      labels                  = optional(map(string))<br>      all_ports               = optional(bool)<br>      network_tier            = optional(string)<br>      service_label           = optional(string)<br>      source_ip_ranges        = optional(list(string))<br>      allow_psc_global_access = optional(bool)<br>      no_automate_dns_zone    = optional(bool)<br>      ip_version              = optional(string)<br>      region                  = optional(string)<br>      recreate_closed_psc     = optional(string)<br>      service_directory_registrations = optional(object({<br>        namespace = optional(string)<br>        service   = optional(string)<br>      }))<br>      metadata_filters = optional(object({<br>        filter_match_criteria = optional(string)<br>        filter_labels = optional(list(object({<br>          name  = optional(string)<br>          value = optional(string)<br>        })))<br>      }))<br>    })))<br>    attachment = optional(map(object({<br>      name                  = string<br>      connection_preference = string<br>      target_service        = string<br>      nat_subnets           = list(string)<br>      enable_proxy_protocol = bool<br>      description           = optional(string)<br>      domain_names          = optional(list(string))<br>      consumer_reject_lists = optional(list(string))<br>      consumer_accept_lists = optional(list(object({<br>        project_id_or_num = string<br>        connection_limit  = number<br>      })))<br>      reconcile_connections = optional(bool)<br>      region                = optional(string)<br>      project               = optional(string)<br>    })))<br>    address = optional(map(object({<br>      name               = string<br>      description        = optional(string)<br>      region             = optional(string)<br>      project            = optional(string)<br>      address            = optional(string)<br>      address_type       = optional(string)<br>      purpose            = optional(string)<br>      network_tier       = optional(string)<br>      subnetwork         = optional(string)<br>      labels             = optional(map(string))<br>      network            = optional(string)<br>      prefix_length      = optional(number)<br>      ip_version         = optional(string)<br>      ipv6_endpoint_type = optional(string)<br>      dns = optional(object({<br>        name            = string<br>        type            = optional(string, "A")<br>        ttl             = optional(number, 300)<br>        managed_zone    = string<br>        project         = optional(string)<br>        rr_data_address = optional(bool)<br>        rr_data         = optional(list(string))<br>      }))<br>    })))<br>  })</pre> | `{}` | no |
| <a name="input_reference"></a> [reference](#input\_reference) | GCP Resource references | <pre>object({<br>    gcp_forwarding_rule_target  = optional(map(any))<br>    gcp_compute_forwarding_rule = optional(map(any))<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gcp_network_endpoint_group"></a> [gcp\_network\_endpoint\_group](#output\_gcp\_network\_endpoint\_group) | GCP Network Endpoint Group resources |
| <a name="output_gcp_psc_address"></a> [gcp\_psc\_address](#output\_gcp\_psc\_address) | GCP Private Service Connect Address resources |
<!-- END_TF_DOCS -->