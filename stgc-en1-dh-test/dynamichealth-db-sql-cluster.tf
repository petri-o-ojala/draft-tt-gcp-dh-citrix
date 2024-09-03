#
# Dynamic Health
#
# Database Insstances
#

module "dynamichealth_db_sql_cluster" {
  source = "./gcp-compute-instance"

  compute                = var.dynamichealth_db_sql_cluster_instance
  compute_instance_group = var.dynamichealth_db_sql_cluster_instance_group
}
