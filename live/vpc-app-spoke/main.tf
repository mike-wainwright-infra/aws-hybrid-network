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
# DYNAMIC DATA SOURCE: READ GLOBAL ROUTER ID FROM AWS SSM PARAMETER VAULT
#----------------------------------------------------------------------------------
data "aws_ssm_parameter" "global_tgw" {
  name = "/network/global-tgw/id"
}

#----------------------------------------------------------------------------------
# NATIVE CORE ENGINE CALL: REUSABLE NETWORK WRAPPER MODULE
#----------------------------------------------------------------------------------
module "app_spoke_vpc" {
  source = "../../modules/vpc"

  vpc_name            = "live-app-spoke"
  vpc_cidr            = "10.200.0.0/16"
  public_subnet_cidr  = "10.200.1.0/24"
  private_subnet_cidr = "10.200.2.0/24"
  tgw_subnet_cidr     = "10.200.3.0/28"
  availability_zone   = "eu-west-2a"

  enable_internet_gateway = false
}

#----------------------------------------------------------------------------------
# TRANSIT ROUTING ENGINE ATTACHMENT
#----------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_tgw_attachment" {
  transit_gateway_id = data.aws_ssm_parameter.global_tgw.value
  vpc_id             = module.app_spoke_vpc.vpc_id
  subnet_ids         = [module.app_spoke_vpc.tgw_subnet_id]

  tags = {
    Name        = "tgw-attach-live-app-spoke"
    Environment = "live-app-spoke"
    ManagedBy   = "Terraform"
  }
}