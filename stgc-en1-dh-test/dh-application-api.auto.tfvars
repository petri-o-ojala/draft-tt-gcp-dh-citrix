#
# DynamicHealth API Service
#

dynamichealth_app_api_instance = {
  #
  # Common Service Account for Dynamichealth API Instances
  #
  service_account = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account
    "dynamichealth-api-instance" : {
      project      = "stgc-en1-dh-test"
      account_id   = "dh-api-instance"
      display_name = "Service Account for Dynamichealth API Instance"
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
  # Dynamichealth API Instances
  #
  instance = {
    # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance
    "dynamichealth-api-instance-a" = {
      project      = "stgc-en1-dh-test"
      name         = "dh-test-api-1"
      machine_type = "e2-standard-2"
      zone         = "europe-north1-a"

      hostname = "dh-test-api-1.terveystalo.com"

      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-api-1"
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
          subnetwork = "https://www.googleapis.com/compute/v1/projects/stgc-en1-dh-test/regions/europe-north1/subnetworks/stgc-en1-dh-test-app-snet"
        }
      ]
      tags = [
        "dynamichealth",
        "test",
        "api"
      ]

      allow_stopping_for_update = true
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
      service_account = {
        email = "dynamichealth-api-instance"
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
            "user:comext-petri.ojala@terveystalo.com"
          ]
        },
        "dynamichealth-api-instance-tunnel" : {
          scope = "iap_tunnel_instance"
          role  = "roles/iap.tunnelResourceAccessor"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-access-instance" : {
          scope = "instance"
          role  = "roles/compute.osAdminLogin"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-service-account" : {
          scope           = "service_account"
          service_account = "dynamichealth-api-instance"
          role            = "roles/iam.serviceAccountUser"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
      }
    },
    "dynamichealth-api-instance-b" = {
      project      = "stgc-en1-dh-test"
      name         = "dh-test-api-2"
      machine_type = "e2-standard-2"
      zone         = "europe-north1-b"

      hostname = "dh-test-api-2.terveystalo.com"

      labels = {
        terraform-managed  = "true"
        terraform-pipeline = "xxx"
        environment        = "test"
        vm-name            = "dh-test-api-2"
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
          subnetwork = "https://www.googleapis.com/compute/v1/projects/stgc-en1-dh-test/regions/europe-north1/subnetworks/stgc-en1-dh-test-app-snet"
        }
      ]
      tags = [
        "dynamichealth",
        "test",
        "api"
      ]

      allow_stopping_for_update = true
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
      service_account = {
        email = "dynamichealth-api-instance"
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
            "user:comext-petri.ojala@terveystalo.com"
          ]
        },
        "dynamichealth-api-instance-tunnel" : {
          scope = "iap_tunnel_instance"
          role  = "roles/iap.tunnelResourceAccessor"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-access-instance" : {
          scope = "instance"
          role  = "roles/compute.osAdminLogin"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
        "dynamichealth-api-instance-service-account" : {
          scope           = "service_account"
          service_account = "dynamichealth-api-instance"
          role            = "roles/iam.serviceAccountUser"
          member = [
            "user:comext-petri.ojala@terveystalo.com"
          ]
        }
      }
    }
  }
}

dynamichealth_app_api_instance_group = {
  #
  # Compute Instance Group for all Dynamichealth API Instances
  #
  group = {
    "dynamichealth-api-a" = {
      project     = "stgc-en1-dh-test"
      name        = "dh-test-api-a"
      description = "Dynamichealth API Instance Group (zone a)"
      zone        = "europe-north1-a"
      instances = [
        "dynamichealth-api-instance-a"
      ]
      named_port = [
        {
          name = "https"
          port = "443"
        }
      ]
    },
    "dynamichealth-api-b" = {
      project     = "stgc-en1-dh-test"
      name        = "dh-test-api-b"
      description = "Dynamichealth API Instance Group (zone b)"
      zone        = "europe-north1-b"
      instances = [
        "dynamichealth-api-instance-b"
      ]
      named_port = [
        {
          name = "https"
          port = "443"
        }
      ]
    },
    "dynamichealth-api-c" = {
      project     = "stgc-en1-dh-test"
      name        = "dh-test-api-c"
      description = "Dynamichealth API Instance Group (zone c)"
      zone        = "europe-north1-c"
      instances = [
      ]
      named_port = [
        {
          name = "https"
          port = "443"
        }
      ]
    }
  }
}

dynamichealth_app_api_load_balancer = {}

dynamichealth_app_api_load_balancer_certificate_manager = {}

