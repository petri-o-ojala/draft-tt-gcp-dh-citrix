#
# Dynamic Health
#
# Cloud NetApp Volumes
#

module "dynamichealth_app_cloud_netapp_volumes" {
  source = "./gcp-cloud-netapp-volumes"

  filestore = var.dynamichealth_app_cloud_netapp_volumes
}
