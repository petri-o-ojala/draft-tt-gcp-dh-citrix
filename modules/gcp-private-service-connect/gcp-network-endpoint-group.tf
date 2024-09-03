#
#
#

resource "google_compute_network_endpoint_group" "lz" {
  for_each = {
    for network_endpoint_group in local.gcp_network_endpoint_group : network_endpoint_group.resource_index => network_endpoint_group
    if network_endpoint_group.region == null
  }

  name                  = each.value.name
  network               = each.value.network
  description           = each.value.description
  network_endpoint_type = each.value.nanetwork_endpoint_type
  subnetwork            = each.value.subnetwork
  default_port          = each.value.default_port
  zone                  = each.value.zone
  project               = each.value.project
}

resource "google_compute_region_network_endpoint_group" "lz" {
  for_each = {
    for network_endpoint_group in local.gcp_network_endpoint_group : network_endpoint_group.resource_index => network_endpoint_group
    if network_endpoint_group.region != null
  }

  name                  = each.value.name
  region                = each.value.region
  network               = each.value.network
  description           = each.value.description
  network_endpoint_type = each.value.network_endpoint_type
  psc_target_service    = each.value.psc_target_service
  subnetwork            = each.value.subnetwork
  project               = each.value.project

  dynamic "cloud_run" {
    # (Optional) This field is only used for SERVERLESS NEGs. Only one of cloud_run, app_engine, cloud_function or serverless_deployment may be set.
    for_each = try(each.value.cloud_run, null) == null ? [] : [1]

    content {
      service  = each.value.cloud_run.service
      tag      = each.value.cloud_run.tag
      url_mask = each.value.cloud_run.url_mask
    }
  }

  dynamic "app_engine" {
    # (Optional) This field is only used for SERVERLESS NEGs. Only one of cloud_run, app_engine, cloud_function or serverless_deployment may be set.
    for_each = try(each.value.app_engine, null) == null ? [] : [1]

    content {
      service  = each.value.app_engine.service
      version  = each.value.app_engine.version
      url_mask = each.value.app_engine.url_mask
    }
  }

  dynamic "cloud_function" {
    # (Optional) This field is only used for SERVERLESS NEGs. Only one of cloud_run, app_engine, cloud_function or serverless_deployment may be set.
    for_each = try(each.value.cloud_function, null) == null ? [] : [1]

    content {
      function = each.value.cloud_function.function
      url_mask = each.value.cloud_function.url_mask
    }
  }

  /*
  dynamic "serverless_deployment" {
    # (Optional) This field is only used for SERVERLESS NEGs. Only one of cloud_run, app_engine, cloud_function or serverless_deployment may be set.
    for_each = try(each.value.serverless_deployment, null) == null ? [] : [1]

    content {
      platform = each.value.serverless_deployment.platform
      resource = each.value.serverless_deployment.resource
      version  = each.value.serverless_deployment.version
      url_mask = each.value.serverless_deployment.url_mask
    }
  }
*/
}

resource "google_compute_network_endpoints" "lz" {
  for_each = {
    for network_endpoint in local.gcp_network_endpoint : network_endpoint.resource_index => network_endpoint
    if network_endpoint.region == null
  }

  network_endpoint_group = google_compute_network_endpoint_group.lz[each.value.network_endpoint_group].name
  project                = each.value.project
  zone                   = each.value.zone

  dynamic "network_endpoints" {
    for_each = coalesce(each.value.network_endpoints, [])

    content {
      instance   = network_endpoints.value.instance
      port       = network_endpoints.value.port
      ip_address = network_endpoints.value.ip_address
    }
  }
}

resource "google_compute_region_network_endpoint" "lz" {
  for_each = {
    for network_endpoint in local.gcp_network_endpoint : network_endpoint.resource_index => network_endpoint
    if network_endpoint.region != null
  }

  port                          = each.value.port
  region_network_endpoint_group = google_compute_region_network_endpoint_group.lz[each.value.network_endpoint_group].name

  ip_address = each.value.ip_address
  fqdn       = each.value.fqdn
  region     = each.value.region
  project    = each.value.project
}
