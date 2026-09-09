#----------------------------------------------------------------------------------
# ENVIRONMENT CONTEXT: CORPORATE ON-PREMISES DATA CENTRE SIMULATOR
# Decoupled Multi-Account Network Wave Strategy - Simulated Legacy Zone
#----------------------------------------------------------------------------------

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

#----------------------------------------------------------------------------------
# NATIVE CORE ENGINE CALL: REUSABLE NETWORK WRAPPER MODULE
#----------------------------------------------------------------------------------
module "onprem_sim_vpc" {
  source = "../../modules/vpc"

  # Aligning input variables precisely with modules/vpc/variables.tf
  vpc_name            = "corporate-onprem-sim"
  vpc_cidr            = "172.16.0.0/16"       # Completely isolated non-AWS IP space
  public_subnet_cidr  = "172.16.1.0/24"       # Dormant/Empty Public Subnet
  private_subnet_cidr = "172.16.2.0/24"       # Host for secure PostgreSQL Database vault
  tgw_subnet_cidr     = "172.16.3.0/28"       # Dedicated attachment point
  availability_zone   = "eu-west-2a"

  # ON-PREMISE ENFORCEMENT: No direct AWS internet gateway allowed
  enable_internet_gateway = false
}

#----------------------------------------------------------------------------------
# TRANSIT ROUTING ENGINE ATTACHMENT
# Bridges the Corporate Data Centre directly into the Global Platform Router Mesh
#----------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "onprem_tgw_attachment" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.onprem_sim_vpc.vpc_id
  subnet_ids         = [module.onprem_sim_vpc.tgw_subnet_id]

  tags = {
    Name        = "tgw-attach-corporate-onprem-sim"
    Environment = "corporate-onprem-sim"
    ManagedBy   = "Terraform"
  }
}