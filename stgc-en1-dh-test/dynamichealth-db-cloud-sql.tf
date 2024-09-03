#
# Dynamic Health
#
# Cloud SQL
#

module "dynamichealth_db_cloud_sql" {
  source = "./gcp-cloud-sql"

  cloud_sql = var.dynamichealth_db_cloud_sql
}

module "dynamichealth_db_cloud_sql_private_connect" {
  source = "./gcp-private-service-connect"

  reference = {
    gcp_forwarding_rule_target = {
      for resource_id, resource in module.dynamichealth_db_cloud_sql.gcp_cloud_sql_instance : resource_id => resource.psc_service_attachment_link
    }
  }

  psc = var.dynamichealth_db_cloud_sql_private_connect
}
