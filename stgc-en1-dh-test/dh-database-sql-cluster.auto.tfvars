#
# DynamicHealth Database SQL Cluster
#

dynamichealth_db_sql_cluster_instance = {
  #
  # Node Template and Group for sole-tenant nodes
  #
  node_template = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_node_template.html
    "sql-cluster" = {
      name        = "dynamichealth-test-sql"
      description = "Dynamichealth Test SQL Instances"
      project     = "stgc-en1-dh-test"
      region      = "europe-north1"
      node_type   = "m1-node-96-1433"
    }
  }
  node_group = {
    "sql-cluster" = {
      name          = "dynamichealth-test-sql"
      project       = "stgc-en1-dh-test"
      zone          = "europe-north1-a"
      description   = "Dynamichealth Test SQL Instances"
      initial_size  = 2
      node_template = "sql-cluster"
    }
  }
  #
  # Common Service Account for Dynamichealth SQL Cluster Instances
  #
  service_account = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
    "dynamichealth-sql-instance" : {
      project      = "stgc-en1-dh-test"
      account_id   = "dh-db-sql-instance"
      display_name = "Service Account for Dynamichealth SQL Instance"
      key = {
        rotation_days = 90
      }
      service_account_iam = [
        /* for IaC pipeline
        {
          role = "roles/iam.serviceAccountUser"
          member = [
            "serviceAccount:iac@project.iam.gserviceaccount.com"
          ]
        }
        */
      ]
      iam = [
        {
          project = "stgc-en1-dh-test"
          role = [
            "roles/logging.logWriter",      # For OSConfigAgent
            "roles/monitoring.metricWriter" # For OSAgent
          ]
        }
      ]
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
      }
    }
  }
  #
  # Dynamichealth SQL Cluster Instances
  #
  instance = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
    "dynamichealth-sql-cluster-instance-1" = {
      project      = "stgc-en1-dh-test"
      name         = "dh-test-sql-cluster-1"
      machine_type = "e2-standard-2"
      zone         = "europe-north1-a"

      hostname = "dh-test-sql-cluster-1.terveystalo.com"

      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-sql-cluster-1"
      }

      boot_disk = {
        initialize_params = {
          type  = "pd-standard"
          size  = 64
          image = "windows-cloud/windows-2022"
        }
      }
      network_interface = [
        {
          subnetwork = "https://www.googleapis.com/compute/v1/projects/stgc-en1-dh-test/regions/europe-north1/subnetworks/stgc-en1-dh-test-db-snet"
        }
      ]
      tags = [
        "dynamichealth",
        "test",
        "sql"
      ]

      allow_stopping_for_update = true
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
      advanced_machine_features = {
        threads_per_core = 1
      }
      node_affinities = {
        key      = "compute.googleapis.com/node-group-name"
        operator = "IN"
        values = [
          "dynamichealth-test-sql"
        ]
      }

      service_account = {
        email = "dynamichealth-sql-instance"
        scopes = [
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring",
          "https://www.googleapis.com/auth/service.management.readonly",
          "https://www.googleapis.com/auth/servicecontrol"
        ]
      }
      metadata = {
        enable-oslogin          = "TRUE",
        enable-os-inventory     = "TRUE",
        enable-guest-attributes = "TRUE"
      }

      iam = [
        #
        # Service Account permissions
        #
        {
          role = "roles/compute.admin"
          member = [
            "dynamichealth-api-instance"
          ]
        }
      ]

      #
      # IAP Access to the instance
      # (We should do this at project level perhaps?)
      #
      iap = {
        "dynamichealth-api-instance-project" : {
          scope = "project"
          role  = "roles/compute.viewer"
          member = [
            "user:ext-petri.ojala@terveystalo.com"
          ]
        },
        "dynamichealth-api-instance-tunnel" : {
          scope = "iap_tunnel_instance"
          role  = "roles/iap.tunnelResourceAccessor"
          member = [
            "user:ext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-access-instance" : {
          scope = "instance"
          role  = "roles/compute.osAdminLogin"
          member = [
            "user:ext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-service-account" : {
          scope           = "service_account"
          service_account = "dynamichealth-sql-instance"
          role            = "roles/iam.serviceAccountUser"
          member = [
            "user:ext-petri.ojala@terveystalo.com"
          ]
        }
      }
    }
  }
  #
  # Data disks for Dynamichealth SQL Cluster
  #
  disk = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk
    "dynamichealth-instance-1-data" = {
      project = "stgc-en1-dh-test"
      name    = "dynamichealth-instance-1-data-disk"
      type    = "pd-ssd"
      zone    = "europe-north1-a"
      size    = 4096
      attachment = {
        instance    = "dynamichealth-sql-cluster-instance-1"
        device_name = "data"
      }
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-sql-cluster-1"
      }
    },
    "dynamichealth-instance-1-log" = {
      project = "stgc-en1-dh-test"
      name    = "dynamichealth-instance-1-log-disk"
      type    = "pd-extreme"
      zone    = "europe-north1-a"
      size    = 128
      attachment = {
        instance    = "dynamichealth-sql-cluster-instance-1"
        device_name = "log"
      }
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-sql-cluster-1"
      }
    },
    "dynamichealth-instance-1-tempdb" = {
      project = "stgc-en1-dh-test"
      name    = "dynamichealth-instance-1-tempdb-disk"
      type    = "pd-ssd"
      zone    = "europe-north1-a"
      size    = 2048
      attachment = {
        instance    = "dynamichealth-sql-cluster-instance-1"
        device_name = "tempdb"
      }
      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-sql-cluster-1"
      }
    }
  }
}

dynamichealth_db_sql_cluster_instance_group = {}

