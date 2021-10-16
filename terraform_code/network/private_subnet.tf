#################### PRIVATE SUBNET ###############################

resource "aws_eip" "nat_gateway_ip" {
  count = var.num_subnets

  vpc = true

  depends_on = [aws_internet_gateway.public_subnet_gw]
  tags = {
    Name = var.tag
  }
}

resource "aws_nat_gateway" "private_subnet_gw"{
  count = var.num_subnets
  subnet_id = aws_subnet.public_subnet[count.index].id

  allocation_id = aws_eip.nat_gateway_ip[count.index].id
  depends_on = [aws_internet_gateway.public_subnet_gw]
  tags = {
    Name = var.tag
  }
}

resource "aws_route_table" "esle_private_network_table" {
  count = var.num_subnets
  vpc_id = aws_vpc.esle_network.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.private_subnet_gw[count.index].id
  }

  tags = {
    Name = var.tag
  }
}

resource "aws_route_table_association" "private_subnet_route" {
  count = var.num_subnets

  subnet_id = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.esle_private_network_table[count.index].id
}


resource "aws_subnet" "private_subnet" {
  count = var.num_subnets

  vpc_id = aws_vpc.esle_network.id
  cidr_block = cidrsubnet("10.0.0.0/16",8,100+count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.tag}-private-subnet-${count.index}"
    "kubernetes.io/role/internal-elb"	= 1,
    "kubernetes.io/cluster/esleCluster" = "owned"
  }
}