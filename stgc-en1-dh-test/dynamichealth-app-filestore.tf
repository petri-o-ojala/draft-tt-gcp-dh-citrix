#
# Dynamic Health
#
# Cloud Filestore
#

module "dynamichealth_app_filestore" {
  source = "./gcp-cloud-filestore"

  filestore = var.dynamichealth_app_filestore
}
