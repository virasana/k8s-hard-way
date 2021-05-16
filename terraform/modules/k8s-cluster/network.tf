data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "vpc_k8s" {
  cidr_block           = var.network_vpc_k8s_cidr_range
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.common_tags,
  {
    description = "vpc-k8s"
  })
}

resource "aws_subnet" "public_k8s" {
  cidr_block        = var.network_subnet_k8s_cidr_range
  vpc_id            = aws_vpc.vpc_k8s.id
  availability_zone = var.network_availability_zone_a
  tags              = merge(local.common_tags,
  {
    description = "public-subnet-k8s"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_k8s.id
  tags   = merge(local.common_tags,
  {
    description = "k8s-internet-gateway"
  })
}

resource "aws_route_table" "rt" {
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

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.public_k8s.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_eip" "eip" {
  vpc      = true
  tags   = merge(local.common_tags,
  {
    description = "k8s-eip"
  })
}