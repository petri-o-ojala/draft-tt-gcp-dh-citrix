#
# IAM Bindings for resources
#

resource "google_organization_iam_member" "lz" {
  #
  # GCP Organization IAM
  #
  for_each = {
    for iam in local.gcp_iam_binding_organization : iam.resource_index => iam
  }

  org_id = each.value.org_id
  role   = each.value.role
  member = each.value.member
}

resource "google_folder_iam_member" "lz" {
  #
  # GCP Folder IAM
  #
  for_each = {
    for iam in local.gcp_iam_binding_folder : iam.resource_index => iam
  }

  folder = startswith(each.value.folder_id, "folders/") ? each.value.folder_id : "folders/${each.value.folder_id}"
  role   = each.value.role
  member = each.value.member
}

resource "google_project_iam_member" "lz" {
  #
  # GCP Project IAM
  #
  for_each = {
    for iam in local.gcp_iam_binding_project : iam.resource_index => iam
  }

  project = each.value.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_service_account_iam_member" "lz" {
  #
  # GCP Service Account IAM
  #
  for_each = {
    for iam in local.gcp_iam_binding_service_account : iam.resource_index => iam
  }

  service_account_id = each.value.service_account_id
  role               = each.value.role
  member             = each.value.member
}

resource "google_storage_bucket_iam_member" "lz" {
  #
  # GCS Bucket IAM
  #
  for_each = {
    for iam in local.gcp_iam_binding_storage_bucket : iam.resource_index => iam
  }

  bucket = each.value.bucket
  role   = each.value.role
  member = each.value.member
}

resource "google_pubsub_topic_iam_member" "lz" {
  #
  # GCS Pub/Sub Topic IAM
  #
  for_each = {
    for iam in local.gcp_pubsub_topic_iam_member : iam.resource_index => iam
  }

  topic   = each.value.topic
  project = each.value.project
  role    = each.value.role
  member  = each.value.member
}

resource "google_pubsub_subscription_iam_member" "lz" {
  #
  # GCS Pub/Sub Subscription IAM
  #
  for_each = {
    for iam in local.gcp_pubsub_subscription_iam_member : iam.resource_index => iam
  }

  subscription = each.value.subscription
  project      = each.value.project
  role         = each.value.role
  member       = each.value.member
}
