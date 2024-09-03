locals {
  gcp_cloud_router = flatten([
    for router_id, router in coalesce(local.vpc.router, {}) : merge(
      router,
      {
        resource_index = join("_", [router_id])
      }
    )
  ])

  gcp_router_interface = flatten([
    for interface_id, interface in coalesce(local.vpc.router_interface, {}) : merge(
      interface,
      {
        resource_index = join("_", [interface_id])
      }
    )
  ])

  gcp_cloud_nat = flatten([
    for nat_id, nat in coalesce(local.vpc.nat, {}) : merge(
      nat,
      {
        resource_index = join("_", [nat_id])
      }
    )
  ])

  /*
  gcp_cloud_nat_address = flatten([
    for address_id, address in coalesce(local.vpc.address, {}) : merge(
      address,
      {
        resource_index = join("_", [address_id])
      }
    )
  ])
*/

  gcp_router_peer = flatten([
    for peer_id, peer in coalesce(local.vpc.router_peer, {}) : merge(
      peer,
      {
        resource_index = join("_", [peer_id])
      }
    )
  ])
}
