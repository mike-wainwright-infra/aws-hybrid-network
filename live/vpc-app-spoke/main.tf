#----------------------------------------------------------------------------------
# ENVIRONMENT CONTEXT: LIVE PRODUCTION APPLICATION SPOKE VPC
# Decoupled Multi-Account Network Wave Strategy - Isolated Internal Zone
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
module "app_spoke_vpc" {
  source = "../../modules/vpc"

  # Aligning input variables precisely with modules/vpc/variables.tf
  vpc_name            = "live-app-spoke"
  vpc_cidr            = "10.200.0.0/16"      # Non-overlapping IP Space
  public_subnet_cidr  = "10.200.1.0/24"      # Dormant/Empty Public Subnet
  private_subnet_cidr = "10.200.2.0/24"      # Host for secure App/EC2 Workloads
  tgw_subnet_cidr     = "10.200.3.0/28"      # Dedicated attachment point
  availability_zone   = "eu-west-2a"

  # STRICT SECURITY ENFORCEMENT: No direct internet edge switch allowed
  enable_internet_gateway = false
}

#----------------------------------------------------------------------------------
# TRANSIT ROUTING ENGINE ATTACHMENT
# Plugs the isolated Application Spoke directly into the Central Router Plane
#----------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_tgw_attachment" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.app_spoke_vpc.vpc_id
  subnet_ids         = [module.app_spoke_vpc.tgw_subnet_id]

  tags = {
    Name        = "tgw-attach-live-app-spoke"
    Environment = "live-app-spoke"
    ManagedBy   = "Terraform"
  }
}