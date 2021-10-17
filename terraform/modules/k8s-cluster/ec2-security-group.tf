resource "aws_security_group" "subnet_public" {
  name   = "subnet_public"
  vpc_id = aws_vpc.vpc_k8s.id
  tags   = merge(local.common_tags,
  {
    description = "subnet-public-security-group"
  })
}

resource aws_security_group_rule "egress_subnet_public_internet_http" {
  type              = "egress"
  cidr_blocks       = [
    "0.0.0.0/0"
  ]
  from_port         = 0
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.subnet_public.id
}

resource aws_security_group_rule "egress_subnet_public_internet_https" {
  type              = "egress"
  cidr_blocks       = [
    "0.0.0.0/0"
  ]
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.subnet_public.id
}

resource aws_security_group_rule "ingress_subnet_public_internet_https" {
  type              = "ingress"
  cidr_blocks       = [
    "0.0.0.0/0"
  ]
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.subnet_public.id
}

resource "aws_security_group" "subnet_private" {
  name   = "subnet_private"
  vpc_id = aws_vpc.vpc_k8s.id
  tags   = merge(local.common_tags,
  {
    description = "subnet-private-security-group"
  })
}

resource aws_security_group_rule "egress_subnet_private_vpc_all" {
  type              = "egress"
  cidr_blocks       = [
    "10.200.0.0/16"
  ]
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.subnet_private.id
}

resource aws_security_group_rule "ingress_subnet_private_vpc_https" {
  type              = "ingress"
  cidr_blocks       = [
    "10.200.0.0/16"
  ]
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.subnet_private.id
}

resource aws_security_group_rule "ingress_subnet_private_vpc_ssh" {
  type              = "ingress"
  cidr_blocks       = [
    "10.200.0.0/16"
  ]
  from_port         = 0
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.subnet_private.id
}

resource aws_security_group_rule "ingress_subnet_private_local" {
  count             = length(var.network_availability_zones)
  type              = "ingress"
  cidr_blocks       = [
    replace(var.network_subnet_private_cidr_mask, "x", count.index)
  ]
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.subnet_private.id
}

resource aws_security_group_rule "egress_subnet_private_local" {
  count             = length(var.network_availability_zones)
  type              = "egress"
  cidr_blocks       = [
    replace(var.network_subnet_private_cidr_mask, "x", count.index)
  ]
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  security_group_id = aws_security_group.subnet_private.id
}

resource "aws_security_group" "ingress-bastion" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.vpc_k8s.id

  ingress {
    cidr_blocks = [
      "${chomp(data.http.myip.body)}/32"
    ]
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
  }

  // Terraform removes the default rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = merge(local.common_tags,
  {
    description = "access-ssh"
  })
}