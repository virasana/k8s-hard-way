data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "vpc_k8s" {
  cidr_block           = var.network_vpc_cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags,
  {
    description = "vpc-k8s"
  })
}

resource "aws_subnet" "public_k8s" {
  cidr_block        = var.network_subnet_public_cidr_range
  vpc_id            = aws_vpc.vpc_k8s.id
  availability_zone = var.network_availability_zones[0]
  tags              = merge(local.common_tags,
  {
    description = "public-subnet-k8s"
  })
}

resource "aws_subnet" "private_k8s" {
  count             = length(var.network_availability_zones)
  cidr_block        = replace(var.network_subnet_private_cidr_mask, "x", count.index)
  vpc_id            = aws_vpc.vpc_k8s.id
  availability_zone = var.network_availability_zones[count.index]
  tags              = merge(local.common_tags,
  {
    description       = "private-subnet-k8s"
    availability_zone = var.network_availability_zones[count.index]
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_k8s.id
  tags   = merge(local.common_tags,
  {
    description = "k8s-internet-gateway"
  })
}

resource "aws_route_table" "rt_public_k8s" {
  vpc_id = aws_vpc.vpc_k8s.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags   = merge(local.common_tags,
  {
    description = "k8s-route-table"
  })
}

resource "aws_nat_gateway" "nat_k8s" {
  subnet_id     = aws_subnet.public_k8s.id
  allocation_id = aws_eip.eip_k8s.id
  tags          = merge(local.common_tags,
  {
    description = "k8s-route-table"
  })
  depends_on    = [
    aws_eip.eip_k8s]
}

resource "aws_route_table" "rt_private_k8s" {
  count  = length(var.network_availability_zones)
  vpc_id = aws_vpc.vpc_k8s.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_k8s.id
  }
  tags = merge(local.common_tags,
  {
    description = "k8s-route-table"
  })
}

resource "aws_route_table_association" "subnet_association_public" {
  subnet_id      = aws_subnet.public_k8s.id
  route_table_id = aws_route_table.rt_public_k8s.id
}

resource "aws_route_table_association" "subnet_association_private" {
  count          = length(var.network_availability_zones)
  subnet_id      = aws_subnet.private_k8s[count.index].id
  route_table_id = aws_route_table.rt_private_k8s[count.index].id
}

resource "aws_eip" "eip_k8s" {
  vpc  = true
  tags = merge(local.common_tags,
  {
    description = "k8s-eip"
  })
}
