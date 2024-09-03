#
# GCP Compute Policies
#

resource "google_compute_disk_resource_policy_attachment" "lz" {
  #
  # GCP Compute Disk resource policy attachments (Zonal)
  #
  for_each = {
    for attachment in local.gcp_compute_disk_resource_policy_attachment : attachment.resource_index => attachment
    if attachment.region == null
  }

  name    = google_compute_resource_policy.lz[each.value.policy_name].name
  disk    = google_compute_disk.lz[each.value.disk_name].name
  zone    = google_compute_disk.lz[each.value.disk_name].zone
  project = google_compute_disk.lz[each.value.disk_name].project
}

resource "google_compute_region_disk_resource_policy_attachment" "lz" {
  #
  # GCP Compute Disk resource policy attachments (Regional)
  #
  for_each = {
    for attachment in local.gcp_compute_disk_resource_policy_attachment : attachment.resource_index => attachment
    if attachment.region != null
  }

  name    = google_compute_resource_policy.lz[each.value.policy_name].name
  disk    = google_compute_region_disk.lz[each.value.disk_name].name
  region  = google_compute_region_disk.lz[each.value.disk_name].region
  project = google_compute_region_disk.lz[each.value.disk_name].project
}

resource "google_compute_resource_policy" "lz" {
  #
  # GCP Compute Resource Policies
  #
  for_each = {
    for policy in local.gcp_compute_resource_policy : policy.resource_index => policy
  }

  provider = google-beta

  name        = each.value.name
  description = each.value.description
  region      = each.value.region
  project     = each.value.project

  dynamic "snapshot_schedule_policy" {
    # (Optional) Policy for creating snapshots of persistent disks. 
    for_each = try(each.value.snapshot_schedule_policy, null) == null ? [] : [1]

    content {
      dynamic "snapshot_properties" {
        # (Optional) Properties with which the snapshots are created, such as labels. 
        for_each = try(each.value.snapshot_schedule_policy.snapshot_properties, null) == null ? [] : [1]

        content {
          labels            = each.value.snapshot_schedule_policy.snapshot_properties.labels
          storage_locations = each.value.snapshot_schedule_policy.snapshot_properties.storage_locations
          guest_flush       = each.value.snapshot_schedule_policy.snapshot_properties.guest_flush
          chain_name        = each.value.snapshot_schedule_policy.snapshot_properties.chain_name
        }
      }

      dynamic "retention_policy" {
        # (Optional) Retention policy applied to snapshots created by this resource policy. 
        for_each = try(each.value.snapshot_schedule_policy.retention_policy, null) == null ? [] : [1]

        content {
          max_retention_days    = each.value.snapshot_schedule_policy.retention_policy.max_retention_days
          on_source_disk_delete = each.value.snapshot_schedule_policy.retention_policy.on_source_disk_delete
        }
      }

      dynamic "schedule" {
        # (Required) Contains one of an hourlySchedule, dailySchedule, or weeklySchedule.
        for_each = try(each.value.snapshot_schedule_policy.schedule, null) == null ? [] : [1]

        content {
          dynamic "hourly_schedule" {
            for_each = try(each.value.snapshot_schedule_policy.schedule.hourly_schedule, null) == null ? [] : [1]

            content {
              hours_in_cycle = each.value.snapshot_schedule_policy.schedule.hourly_schedule.hours_in_cycle
              start_time     = each.value.snapshot_schedule_policy.schedule.hourly_schedule.start_time
            }
          }

          dynamic "daily_schedule" {
            for_each = try(each.value.snapshot_schedule_policy.schedule.daily_schedule, null) == null ? [] : [1]

            content {
              days_in_cycle = each.value.snapshot_schedule_policy.schedule.daily_schedule.days_in_cycle
              start_time    = each.value.snapshot_schedule_policy.schedule.daily_schedule.start_time
            }
          }

          dynamic "weekly_schedule" {
            for_each = try(each.value.snapshot_schedule_policy.schedule.weekly_schedule, null) == null ? [] : [1]

            content {
              dynamic "day_of_weeks" {
                for_each = try(each.value.snapshot_schedule_policy.schedule.weekly_schedule.day_of_weeks, null) == null ? [] : [1]

                content {
                  start_time = each.value.snapshot_schedule_policy.schedule.weekly_schedule.day_of_weeks.start_time
                  day        = each.value.snapshot_schedule_policy.schedule.weekly_schedule.day_of_weeks.day
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "group_placement_policy" {
    # (Optional) Resource policy for instances used for placement configuration. 
    for_each = try(each.value.group_placement_policy, null) == null ? [] : [1]

    content {
      vm_count                  = each.value.group_placement_policy.vm_count
      availability_domain_count = each.value.group_placement_policy.availability_domain_count
      collocation               = each.value.group_placement_policy.collocation
      max_distance              = each.value.group_placement_policy.max_distance
    }
  }

  dynamic "instance_schedule_policy" {
    # (Optional) Resource policy for scheduling instance operations. 
    for_each = try(each.value.instance_schedule_policy, null) == null ? [] : [1]

    content {
      time_zone       = each.value.instance_schedule_policy.time_zone
      start_time      = each.value.instance_schedule_policy.start_time
      expiration_time = each.value.instance_schedule_policy.expiration_time

      dynamic "vm_start_schedule" {
        # (Optional) Specifies the schedule for starting instances.
        for_each = try(each.value.instance_schedule_policy.vm_start_schedule, null) == null ? [] : [1]

        content {
          schedule = each.value.instance_schedule_policy.vm_start_schedule.schedule
        }
      }

      dynamic "vm_stop_schedule" {
        #  (Optional) Specifies the schedule for stopping instances.
        for_each = try(each.value.instance_schedule_policy.vm_stop_schedule, null) == null ? [] : [1]

        content {
          schedule = each.value.instance_schedule_policy.vm_stop_schedule.schedule
        }
      }
    }
  }

  dynamic "disk_consistency_group_policy" {
    # (Optional) Replication consistency group for asynchronous disk replication.
    for_each = try(each.value.disk_consistency_group_policy, null) == null ? [] : [1]

    content {
      enabled = each.value.disk_consistency_group_policy.enabled
    }
  }
}
