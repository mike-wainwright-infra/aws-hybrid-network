output "transit_gateway_id" {
  value       = aws_ec2_transit_gateway.core_router.id
  description = "The generated ID of the central enterprise Transit Gateway core router"
}

output "ssm_parameter_path" {
  value       = aws_ssm_parameter.tgw_id.name
  description = "The global AWS SSM Parameter Store engine path holding the routing core ID"
}
