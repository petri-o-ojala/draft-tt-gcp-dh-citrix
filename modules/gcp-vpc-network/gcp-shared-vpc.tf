#
# GCP Shared VPCs
#

resource "google_compute_shared_vpc_host_project" "lz" {
  #
  # Shared VPC host projects
  #
  for_each = {
    for vpc in local.gcp_shared_vpc_host : vpc.resource_index => vpc
  }

  project = each.value.project

  depends_on = [
    google_compute_network.lz
  ]
}

resource "google_compute_shared_vpc_service_project" "lz" {
  #
  # Shared VPC  service projects
  #
  for_each = {
    for vpc in local.gcp_shared_vpc_service : vpc.resource_index => vpc
  }

  host_project    = each.value.host_project
  service_project = each.value.service_project
  deletion_policy = try(each.value.deletion_policy, null)

  depends_on = [
    google_compute_network.lz,
    google_compute_shared_vpc_host_project.lz
  ]
}
