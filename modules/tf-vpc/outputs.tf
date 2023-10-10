output "main-vpc-id" {
  value = aws_vpc.vpc_id.id
}

output "subnet-private" {
  value = aws_subnet.private_subnet_a.id
}

output "subnet-public" {
  value = aws_subnet.public_subnet_b.id
}


