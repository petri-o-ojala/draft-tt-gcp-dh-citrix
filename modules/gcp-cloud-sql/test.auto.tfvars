cloud_sql = {
  instance = {
    "demo1" = {
      name             = "my-database-instance"
      region           = "europe-north1"
      database_version = "MYSQL_8_0"
      settings = {
        tier                        = "db-f1-micro"
        deletion_protection_enabled = false
        ip_configuration = {
          psc_config = {
            psc_enabled = true
            allowed_consumer_projects = [
              "ojala-1-devops-cloud-iac"
            ]
          }
          ipv4_enabled                                  = false
          enable_private_path_for_google_cloud_services = true
        }
        backup_configuration = {
          enabled            = true
          binary_log_enabled = true
        }
        availability_type = "REGIONAL"
      }
      database = {
        "demo-db" = {
          name = "my-database"
        }
      }
    }
  }
}
