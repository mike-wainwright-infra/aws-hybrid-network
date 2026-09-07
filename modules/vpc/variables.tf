variable "vpc_name" {
  type        = string
  description = "The deployment name for the enterprise VPC perimeter"
}

variable "vpc_cidr" {
  type        = string
  description = "The primary IPv4 allocation space (CIDR block) for this VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "The IPv4 space for the edge public subnet (ingress/egress)"
}

variable "private_subnet_cidr" {
  type        = string
  description = "The IPv4 space for the isolated backend workload subnet"
}

variable "tgw_subnet_cidr" {
  type        = string
  description = "The tiny dedicated IPv4 slice for hosting the Transit Gateway attachment"
}

variable "availability_zone" {
  type        = string
  description = "The target Availability Zone for local infrastructure deployment"
  default     = "eu-west-2a"
}

variable "enable_internet_gateway" {
  type        = bool
  description = "Toggles the deployment of an Internet Gateway (true for Hub, false for Spoke/On-Prem)"
  default     = false
}