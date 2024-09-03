#
# Dynamic Health
#
# Application API Instances
#

module "dynamichealth_app_api_instance" {
  source = "./gcp-compute-instance"

  compute                = var.dynamichealth_app_api_instance
  compute_instance_group = var.dynamichealth_app_api_instance_group
}

#
# GCLB for DynamicHealth API 

module "dynamichealth_app_api_load_balancer_certificate_manager" {
  source = "./gcp-certificate-manager"

  certificate_manager = var.dynamichealth_app_api_load_balancer_certificate_manager
}

module "dynamichealth_app_api_load_balancer" {
  source = "./gcp-load-balancer"

  reference = {
    gcp_certificate_manager_certificate     = module.dynamichealth_app_api_load_balancer_certificate_manager.gcp_certificate_manager_certificate
    gcp_certificate_manager_certificate_map = module.dynamichealth_app_api_load_balancer_certificate_manager.gcp_certificate_manager_certificate_map
  }
  gclb = var.dynamichealth_app_api_load_balancer
}
