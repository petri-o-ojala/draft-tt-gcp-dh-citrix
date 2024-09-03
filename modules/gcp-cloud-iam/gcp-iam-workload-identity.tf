#
# GCP Workload Identities
#

locals {
  google_iam_workload_identity_pool          = google_iam_workload_identity_pool.lz
  google_iam_workload_identity_pool_provider = google_iam_workload_identity_pool_provider.lz
}

resource "google_iam_workload_identity_pool" "lz" {
  #
  # GCP Workload Identities
  #
  for_each = {
    for pool in local.gcp_workload_identity_pool : pool.resource_index => pool
  }

  workload_identity_pool_id = each.value.workload_identity_pool_id
  display_name              = each.value.display_name
  description               = each.value.description
  disabled                  = each.value.disabled
  project                   = each.value.project
}

resource "google_iam_workload_identity_pool_provider" "lz" {
  #
  # GCP Workload Identity Providers
  #
  for_each = {
    for provider in local.gcp_workload_identity_pool_provider : provider.resource_index => provider
  }

  workload_identity_pool_id          = each.value.workload_identity_pool_id
  workload_identity_pool_provider_id = each.value.workload_identity_pool_provider_id
  display_name                       = each.value.display_name
  description                        = each.value.description
  disabled                           = each.value.disabled
  project                            = each.value.project

  attribute_mapping   = each.value.attribute_mapping
  attribute_condition = each.value.attribute_condition

  dynamic "aws" {
    for_each = try(each.value.aws, null) == null ? [] : [1]

    content {
      account_id = each.value.aws.account_id
    }
  }

  dynamic "oidc" {
    for_each = try(each.value.oidc, null) == null ? [] : [1]

    content {
      allowed_audiences = each.value.oidc.allowed_audiences
      issuer_uri        = each.value.oidc.issuer_uri
      jwks_json         = each.value.oidc.jwks_json
    }
  }

  dynamic "saml" {
    for_each = try(each.value.saml, null) == null ? [] : [1]

    content {
      idp_metadata_xml = each.value.aws.idp_metadata_xml
    }
  }

  depends_on = [
    google_iam_workload_identity_pool.lz
  ]
}
