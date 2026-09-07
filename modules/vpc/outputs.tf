output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The generated ID of the primary VPC container"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "The generated ID of the edge public subnet"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "The generated ID of the isolated private subnet"
}

output "tgw_subnet_id" {
  value       = aws_subnet.tgw.id
  description = "The generated ID of the dedicated Transit Gateway attachment subnet"
}