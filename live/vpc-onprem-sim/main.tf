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
# DYNAMIC DATA SOURCE: READ GLOBAL ROUTER ID FROM AWS SSM PARAMETER VAULT
#----------------------------------------------------------------------------------
data "aws_ssm_parameter" "global_tgw" {
  name = "/network/global-tgw/id"
}

#----------------------------------------------------------------------------------
# NATIVE CORE ENGINE CALL: REUSABLE NETWORK WRAPPER MODULE
#----------------------------------------------------------------------------------
module "onprem_sim_vpc" {
  source = "../../modules/vpc"

  vpc_name            = "corporate-onprem-sim"
  vpc_cidr            = "172.16.0.0/16"
  public_subnet_cidr  = "172.16.1.0/24"
  private_subnet_cidr = "172.16.2.0/24"
  tgw_subnet_cidr     = "172.16.3.0/28"
  availability_zone   = "eu-west-2a"

  enable_internet_gateway = false
}

#----------------------------------------------------------------------------------
# TRANSIT ROUTING ENGINE ATTACHMENT
#----------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "onprem_tgw_attachment" {
  transit_gateway_id = data.aws_ssm_parameter.global_tgw.value
  vpc_id             = module.onprem_sim_vpc.vpc_id
  subnet_ids         = [module.onprem_sim_vpc.tgw_subnet_id]

  tags = {
    Name        = "tgw-attach-corporate-onprem-sim"
    Environment = "corporate-onprem-sim"
    ManagedBy   = "Terraform"
  }
}