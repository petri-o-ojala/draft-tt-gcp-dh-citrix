#
# GCP IAM Audit Configurations
#

resource "google_organization_iam_audit_config" "lz" {
  #
  # GCP Deny Policies
  #
  for_each = {
    for config in local.gcp_iam_organization_audit_config : config.resource_index => config
  }

  org_id  = each.value.org_id
  service = each.value.service

  dynamic "audit_log_config" {
    # The configuration for logging of each type of permission. This can be specified multiple times. 
    for_each = coalesce(each.value.audit_log_config, [])

    content {
      log_type         = audit_log_config.value.log_type
      exempted_members = audit_log_config.value.exempted_members
    }
  }
}
