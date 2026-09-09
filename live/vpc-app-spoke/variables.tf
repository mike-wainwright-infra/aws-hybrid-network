variable "aws_region" {
  type        = string
  description = "Target deployment AWS region mesh"
  default     = "eu-west-2"
}

variable "transit_gateway_id" {
  type        = string
  description = "The target central platform Transit Gateway core router ID"
}