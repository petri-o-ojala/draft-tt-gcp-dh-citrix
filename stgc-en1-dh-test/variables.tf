#
# DynamicHealth Common settings
#

variable "dynamichealth_network_alias" {
  description = "Network aliases"
  type        = any
  default     = null
}

#
# DynamicHealth Application infrastructure
#


variable "dynamichealth_app_vpc" {
  description = "DynamicHealth Application VPC"
  type        = any
  default     = null
}

variable "dynamichealth_app_cloud_netapp_volumes" {
  description = "DynamicHealth Application Cloud Netapp Volumes"
  type        = any
  default     = null
}

variable "dynamichealth_app_filestore" {
  description = "DynamicHealth Application Cloud Filestore"
  type        = any
  default     = null
}

variable "dynamichealth_app_instance" {
  description = "DynamicHealth Application Instances"
  type        = any
  default     = null
}

variable "dynamichealth_app_api_instance" {
  description = "DynamicHealth Application API Instances"
  type        = any
  default     = null
}

variable "dynamichealth_app_api_instance_group" {
  description = "DynamicHealth Application API Instance Groups"
  type        = any
  default     = null
}

variable "dynamichealth_app_api_load_balancer" {
  description = "DynamicHealth Application API Load Balancer"
  type        = any
  default     = null
}

variable "dynamichealth_app_api_load_balancer_certificate_manager" {
  description = "DynamicHealth Application API Load Balancer Certificate Manager"
  type        = any
  default     = null
}

#
# DynamicHealth Database infrastructure
#

variable "dynamichealth_db_vpc" {
  description = "DynamicHealth Database VPC"
  type        = any
  default     = null
}

variable "dynamichealth_db_cloud_sql" {
  description = "DynamicHealth Database Cloud SQL"
  type        = any
  default     = null
}

variable "dynamichealth_db_cloud_sql_private_connect" {
  description = "DynamicHealth Database Cloud SQL Private Service Connect"
  type        = any
  default     = null
}

variable "dynamichealth_db_sql_cluster_instance" {
  description = "DynamicHealth Database SQL Cluster Instances"
  type        = any
  default     = null
}

variable "dynamichealth_db_sql_cluster_instance_group" {
  description = "DynamicHealth Database SQL Cluster Instance Groups"
  type        = any
  default     = null
}
