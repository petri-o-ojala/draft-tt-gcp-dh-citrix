compute_instance_group = {
  template = {
    "dmz-haproxy" = {
      name_prefix  = "dmz-haproxy"
      regional     = false
      region       = "europe-north1"
      machine_type = "n2-standard-2"
      scheduling = {
        automatic_restart   = true
        on_host_maintenance = "MIGRATE"
      }
      network_interface = [
        {
          subnetwork = "https://www.googleapis.com/compute/v1/projects/arek-hyte-dmz-networking/regions/europe-north1/subnetworks/snet-hyte-dmz-gke"
        }
      ]
      disk = [
        {
          boot         = true
          source_image = "debian-cloud/debian-12"
          auto_delete  = true
        }
      ]
      metadata_startup_script = "echo hi > /test.txt"
      shielded_instance_config = {
        enable_secure_boot          = true
        enable_vtpm                 = true
        enable_integrity_monitoring = true
      }
    }
  }
}


compute = {
  service_account = {
    "sa-demovm1" : {
      account_id   = "sa-demo-vm1"
      display_name = "Service Account for demo VM1"
      key = {
        rotation_days = 30
      }
      service_account_iam = [
        {
          role = "roles/iam.serviceAccountUser"
          member = [
            "user:petri.ojala@gmail.com",
            "user:petri@ojala.cloud",
            "domain:ojala.cloud"
          ]
        }
      ]
    }
  }
  instance = {
    "demovm1" = {
      name         = "my-instance"
      machine_type = "n2-standard-2"
      zone         = "europe-north1-c"
      tags = [
        "foo",
        "bar"
      ]

      boot_disk = {
        initialize_params = {
          image = "centos-cloud/centos-stream-9"
          labels = {
            my_label = "value"
          }
        }
      }
      scratch_disk = [
        {
          interface = "NVME"
        }
      ]
      network_interface = [
        {
          network    = "vnet-cameyo"
          subnetwork = "snet-cameyo"
        }
      ]
      metadata = {
        foo = "bar"
      }
      allow_stopping_for_update = true
      service_account = {
        email = "sa-demovm1"
        scopes = [
          "https://www.googleapis.com/auth/devstorage.read_only",
          "https://www.googleapis.com/auth/logging.write",
          "https://www.googleapis.com/auth/monitoring",
          "https://www.googleapis.com/auth/service.management.readonly",
          "https://www.googleapis.com/auth/servicecontrol"
        ]
      }
      metadata_startup_script = "echo hi > /test.txt"
      iam = [
        {
          role = "roles/compute.admin"
          member = [
            "user:petri.ojala@gmail.com",
            "sa-demovm1"
          ]
        }
      ]
      disk = {
        "vmdisk1" = {
          name                      = "test-vm-disk"
          type                      = "pd-ssd"
          zone                      = "europe-north1-c"
          size                      = 12
          physical_block_size_bytes = 4096
          labels = {
            environment = "dev"
          }
          iam = [
            {
              role = "roles/compute.storageAdmin"
              member = [
                "user:petri.ojala@gmail.com"
              ]
            }
          ]
        }
      }
    }
  }
  disk = {
    "demodisk1" = {
      name                      = "test-disk"
      type                      = "pd-ssd"
      zone                      = "europe-north1-a"
      image                     = "centos-cloud/centos-stream-9"
      physical_block_size_bytes = 4096
      labels = {
        environment = "dev"
      }
      iam = [
        {
          role = "roles/compute.storageAdmin"
          member = [
            "user:petri.ojala@gmail.com"
          ]
        }
      ]
    }
  }
  address = {
    "demo1" = {
      name         = "ip-demo1"
      address_type = "INTERNAL"
      subnetwork   = "snet-cameyo"
      region       = "europe-north1"
    }
    "demo2" = {
      name         = "ip-demo2"
      address_type = "EXTERNAL"
      region       = "europe-north1"
    }
  }
}
