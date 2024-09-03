#
# DynamicHealth Application Storage
#

dynamichealth_app_cloud_netapp_volumes = {
  storage_pool = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_storage_pool
    #
    # Cloud Volumes Pool (Flexible) for Dynamic Health
    #
    "dynamichealth-test" = {
      name          = "dh-app-storage"
      service_level = "PREMIUM"
      capacity_gib  = "2048"
      network       = "dh-app-vpc"
      location      = "europe-north1"
    }
  }
  volume = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/netapp_volume
    # 
    # Cloud Volume Dynamic Health Application
    #
    "dynamichealth-application" = {
      name         = "dynamichealth-application"
      location     = "europe-north1"
      capacity_gib = "1024"
      share_name   = "app"
      storage_pool = "dynamichealth-test"
      protocols = [
        "NFSV3"
      ]
      deletion_policy = "DEFAULT"
    },
    # 
    # Cloud Volume Dynamic Health Data
    #
    "dynamichealth-data" = {
      name         = "dynamichealth-data"
      location     = "europe-north1"
      capacity_gib = "1024"
      share_name   = "data"
      storage_pool = "dynamichealth-test"
      protocols = [
        "NFSV3"
      ]
      deletion_policy = "DEFAULT"
    }
  }
}

dynamichealth_app_filestore = {
  instance = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/filestore_instance
    "dh-app-filestore" = {
      project     = "stgc-en1-dh-test"
      name        = "dh-test-filestore"
      description = "Dynamichealth Test Filestore"
      location    = "europe-north1-a"
      tier        = "BASIC_HDD"
      file_shares = [
        {
          capacity_gb = 1024
          name        = "share"
          nfs_export_options = [
            {
              ip_ranges = [
                "10.0.0.0/16"
              ]
              access_mode = "READ_WRITE"
              squash_mode = "NO_ROOT_SQUASH"
            }
          ]
        }
      ]
      networks = [
        {
          network = "projects/stgc-en1-dh-test/global/networks/dh-db-vpc"
          modes = [
            "MODE_IPV4"
          ]
          connect_mode = "PRIVATE_SERVICE_ACCESS"
        }
      ]
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
      }
    }
  }
}
