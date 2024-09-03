#
# DynamicHealth Application Network
#

dynamichealth_db_vpc = {
  network = {
    "dh-db-vpc" = {
      # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network
      #
      # VPC for DynamicHealth SQL Clsuter
      #
      name                    = "stgc-en1-dh-test-db-vpc"
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
        "dh-db" = {
          #
          # Subnet for DynamicHealth SQL Cluster
          #
          project                  = "stgc-en1-dh-test"
          region                   = "europe-north1"
          name                     = "stgc-en1-dh-test-db-snet"
          private_ip_google_access = true
          ip_cidr_range            = "10.11.0.0/16"
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
