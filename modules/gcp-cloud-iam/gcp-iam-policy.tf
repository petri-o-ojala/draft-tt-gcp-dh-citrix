#
# GCP IAM Policies
#

resource "google_iam_deny_policy" "lz" {
  #
  # GCP Deny Policies
  #
  for_each = {
    for policy in local.gcp_iam_deny_policy : policy.resource_index => policy
  }

  name         = each.value.name
  parent       = each.value.parent
  display_name = each.value.display_name

  dynamic "rules" {
    # (Required) Rules to be applied.
    for_each = coalesce(each.value.rules, [])

    content {
      description = rules.value.description

      dynamic "deny_rule" {
        # (Optional) A deny rule in an IAM deny policy.
        for_each = try(rules.value.deny_rule, null) == null ? [] : [1]

        content {
          denied_principals     = rules.value.deny_rule.denied_principals
          exception_principals  = rules.value.deny_rule.exception_principals
          denied_permissions    = rules.value.deny_rule.denied_permissions
          exception_permissions = rules.value.deny_rule.exception_permissions

          dynamic "denial_condition" {
            # (Optional) User defined CEVAL expression. A CEVAL expression is used to specify match criteria such 
            # as origin.ip, source.region_code and contents in the request header. 
            for_each = try(rules.value.deny_rule.denial_condition, null) == null ? [] : [1]

            content {
              expression  = rules.value.deny_rule.denial_condition.expression
              title       = rules.value.deny_rule.denial_condition.title
              description = rules.value.deny_rule.denial_condition.description
              location    = rules.value.deny_rule.denial_condition.location
            }
          }
        }
      }
    }
  }
}

