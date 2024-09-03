#
# Dynamic Health
#
# Application VPC
#

module "dynamichealth_app_vpc" {
  source = "./gcp-vpc-network"

  vpc   = var.dynamichealth_app_vpc
  alias = var.dynamichealth_network_alias
}

# Add PSC, DNS, etc if needed as part of networking
#
