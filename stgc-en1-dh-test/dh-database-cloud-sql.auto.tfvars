#
# DynamicHealth Database Cloud SQL
#

dynamichealth_db_cloud_sql = {
  #
  # Cloud SQL admin credentials in Secret Manager
  #
  secret = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/secret_manager_secret_version
    # https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
    "test-cloudsql-root" = {
      project   = "stgc-en1-dh-test"
      secret_id = "dynamichealth-test-cloudsql-root"
      replication = {
        user_managed = {
          replicas = [
            {
              location = "europe-west1"
            }
          ]
        }
      }
      random_password = {
        length      = 16
        min_upper   = 2
        min_lower   = 2
        min_numeric = 2
        min_special = 2
      }
    }
  }
  #
  # Cloud SQL Instances
  #
  instance = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance
    "dynamichealth-test-cloudsql" = {
      project             = "stgc-en1-dh-test"
      name                = "dynamichealth-test-cloudsql"
      region              = "europe-north1"
      deletion_protection = false
      availability_type   = "ZONAL"
      database_version    = "POSTGRES_15"
      root_password       = "test-cloudsql-root"
      settings = {
        tier                        = "db-f1-micro"
        deletion_protection_enabled = false
        ip_configuration = {
          psc_config = {
            psc_enabled = true
            allowed_consumer_projects = [
              "stgc-en1-dh-test"
            ]
          }
          ipv4_enabled                                  = false
          enable_private_path_for_google_cloud_services = true
          ssl_mode                                      = "ENCRYPTED_ONLY"
        }
        availability_type = "REGIONAL"
      }
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
      }
    }
} }

#
# Cloud SQL Private Connect
#
dynamichealth_db_cloud_sql_private_connect = {
  address = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_address
    "dynamichealth-test-cloudsql" = {
      project      = "stgc-en1-dh-test"
      name         = "psc-dynamichealth-test-cloudsql"
      region       = "europe-north1"
      address_type = "INTERNAL"
      subnetwork   = "https://www.googleapis.com/compute/v1/projects/stgc-en1-dh-test/regions/europe-north1/subnetworks/stgc-en1-dh-test-db-snet"
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
      }
      # Add dns{} if needed
    }
  }
  forwarding_rule = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_forwarding_rule
    "dynamichealth-test-cloudsql" = {
      project               = "stgc-en1-dh-test"
      name                  = "psc-dynamichealth-test-cloudsql"
      region                = "europe-north1"
      network               = "https://www.googleapis.com/compute/v1/projects/stgc-en1-dh-test/global/networks/stgc-en1-dh-test-db-vpc"
      ip_address            = "dynamichealth-test-cloudsql"
      load_balancing_scheme = ""
      target                = "dynamichealth-test-cloudsql" # psc_service_attachment_link from resource
    }
  }
}
