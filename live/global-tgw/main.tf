terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2" # London Region
}

# 1. The Core Enterprise Transit Gateway Router
resource "aws_ec2_transit_gateway" "core_router" {
  description                     = "Central Enterprise Hub-and-Spoke Router Plane"
  amazon_side_asn                 = 64512 # Custom Private ASN for BGP routing consistency
  default_route_table_association = "disable" # TURNED OFF: Forces explicit senior-level route mapping
  default_route_table_propagation = "disable" # TURNED OFF: Prevents sloppy automatic spoke talking

  tags = {
    Name = "enterprise-core-tgw"
  }
}

# 2. Exporting the TGW ID to the AWS System Manager (SSM) Parameter Store
# This allows our completely independent VPC folders to automatically read and link to this router.
resource "aws_ssm_parameter" "tgw_id" {
  name        = "/network/global-tgw/id"
  type        = "String"
  value       = aws_ec2_transit_gateway.core_router.id
  description = "The shared global AWS Transit Gateway ID for environment attachments"
}