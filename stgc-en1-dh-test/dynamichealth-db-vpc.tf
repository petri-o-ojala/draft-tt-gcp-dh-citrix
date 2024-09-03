#
# Dynamic Health
#
# Database VPC
#

module "dynamichealth_db_vpc" {
  source = "./gcp-vpc-network"

  vpc   = var.dynamichealth_db_vpc
  alias = var.dynamichealth_network_alias
}

# Add PSC, DNS, etc if needed as part of networking
#
