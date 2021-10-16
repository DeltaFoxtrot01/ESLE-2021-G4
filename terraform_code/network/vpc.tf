resource "aws_vpc" "esle_network"{
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = var.tag
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

