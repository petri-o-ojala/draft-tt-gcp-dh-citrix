locals {
  compute_instance_iap_permission = flatten([
    for compute_instance_id, compute_instance in coalesce(try(local.compute_instance, null), {}) : [
      for iap_id, iap in coalesce(compute_instance.iap, {}) : [
        for member in coalesce(iap.member, []) :
        {
          iap_id              = iap_id
          compute_instance_id = compute_instance_id
          project             = compute_instance.project
          scope               = iap.scope
          role                = iap.role
          service_account     = iap.service_account
          instance            = compute_instance_id
          member              = member
          resource_index      = join("_", [compute_instance_id, iap_id, member])
        }
      ]
    ]
  ])
}
