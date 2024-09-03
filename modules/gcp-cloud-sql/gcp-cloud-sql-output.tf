#
# Terraform module outputs
#

output "gcp_cloud_sql_instance" {
  description = "Cloud SQL Instance resources"
  value       = google_sql_database_instance.lz
  sensitive   = true
}

output "gcp_cloud_sql_database" {
  description = "Cloud SQL Database resources"
  value       = google_sql_database.lz
}
