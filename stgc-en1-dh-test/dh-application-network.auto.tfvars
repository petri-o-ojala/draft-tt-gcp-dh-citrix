#
# DynamicHealth Application Network
#

dynamichealth_app_vpc = {
  network = {
    "dh-app-vpc" = {
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
      #
      # VPC for DynamicHealth Application
      #
      name                    = "stgc-en1-dh-test-app-vpc"
      description             = "DH Test Application VPC"
      project                 = "stgc-en1-dh-test"
      auto_create_subnetworks = false
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
      }
      subnet = {
        # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork
        "dh-app" = {
          #
          # Subnet for DynamicHealth Application
          #
          project                  = "stgc-en1-dh-test"
          region                   = "europe-north1"
          name                     = "stgc-en1-dh-test-app-snet"
          private_ip_google_access = true
          ip_cidr_range            = "10.10.0.0/16"
          labels = {
            terraform-managed  = "true"
            terraform-pipeline = "xxx"
            environment        = "test"
          }
        }
      }
    }
  }
}
