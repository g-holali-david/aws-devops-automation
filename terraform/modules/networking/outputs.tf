output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR du VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = aws_subnet.public[*].id
}

output "internet_gateway_id" {
  description = "ID de l'Internet Gateway"
  value       = aws_internet_gateway.main.id
}
