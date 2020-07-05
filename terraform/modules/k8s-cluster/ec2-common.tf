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
      "0.0.0.0/0"
    ]
    from_port   = 22
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