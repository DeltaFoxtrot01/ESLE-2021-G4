#################### PUBLIC SUBNET ###############################

resource "aws_internet_gateway" "public_subnet_gw" {

  vpc_id = aws_vpc.esle_network.id

  tags = {
    Name = var.tag
  }
}

resource "aws_route_table" "esle_public_network_table" {
  
  vpc_id = aws_vpc.esle_network.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_subnet_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.public_subnet_gw.id
  }

  tags = {
    Name = var.tag
  }
}

resource "aws_route_table_association" "public_subnet_route" {
  count = var.num_subnets
  subnet_id = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.esle_public_network_table.id
}

resource "aws_subnet" "public_subnet" {
  count = var.num_subnets
  
  vpc_id = aws_vpc.esle_network.id
  cidr_block = cidrsubnet("10.0.0.0/16",8,count.index)
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.tag}-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = count.index == 0 ? 1: 0,
    "kubernetes.io/cluster/esleCluster" = "owned"
  }
}

