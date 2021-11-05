
output "vpc" {
  value = aws_vpc.esle_network
}

#main public subnet
output "public_subnets" {
  value = aws_subnet.public_subnet
}

output "internet_gateway" {
  value = aws_internet_gateway.public_subnet_gw
}
