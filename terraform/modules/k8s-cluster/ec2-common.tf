resource "aws_key_pair" "ec2" {
  public_key = file("/root/.ssh/id_rsa.pub")

  key_name   = "ksone"
  tags       = merge(local.common_tags,
  {
    description = "key-pair-ec2"
  })

}

resource "aws_security_group" "ingress-all" {
  name   = "allow-all-sg"
  vpc_id = aws_vpc.vpc_k8s.id
  ingress {
    cidr_blocks = [
      "10.240.0.0/24",
      "10.200.0.0/16"
    ]
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = [
      "10.240.0.0/24",
      "10.200.0.0/16"
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