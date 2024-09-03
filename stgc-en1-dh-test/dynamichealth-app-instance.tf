#
# Dynamic Health
#
# Application Compute Instances
#

module "dynamichealth_app_instance" {
  source = "./gcp-compute-instance"

  filestore = var.dynamichealth_app_instance
}
