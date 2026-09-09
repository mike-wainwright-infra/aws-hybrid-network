#----------------------------------------------------------------------------------
# ENVIRONMENT CONTEXT: LIVE CORE EGRESS HUB VPC
# Decoupled Multi-Account Network Wave Strategy
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
module "core_hub_vpc" {
  source = "../../modules/vpc"

  # Aligning input variables precisely with modules/vpc/variables.tf
  vpc_name            = "live-core-hub"
  vpc_cidr            = "10.100.0.0/16"
  public_subnet_cidr  = "10.100.1.0/24"
  private_subnet_cidr = "10.100.2.0/24"
  tgw_subnet_cidr     = "10.100.3.0/28"
  availability_zone   = "eu-west-2a"

  # Toggles the conditional Internet Gateway build inside the module
  enable_internet_gateway = true
}

#----------------------------------------------------------------------------------
# TRANSIT ROUTING ENGINE ATTACHMENT
#----------------------------------------------------------------------------------
resource "aws_ec2_transit_gateway_vpc_attachment" "hub_tgw_attachment" {
  # Dynamically fetches the value out of the SSM Data Source instead of using a raw variable
  transit_gateway_id = data.aws_ssm_parameter.global_tgw.value
  vpc_id             = module.core_hub_vpc.vpc_id
  subnet_ids         = [module.core_hub_vpc.tgw_subnet_id]

  tags = {
    Name        = "tgw-attach-live-core-hub"
    Environment = "live-core-hub"
    ManagedBy   = "Terraform"
  }
}