//resource "aws_lb" "kubernetes" {
//  name               = "k8s-alb"
//  internal           = false
//  load_balancer_type = "application"
//  security_groups    = [aws_security_group.ingress-alb.id]
//  subnets            = [aws_subnet.public_k8s.id]
//
//  enable_deletion_protection = false
//
//  tags = merge(local.common_tags,
//  {
//    Name        = "alb-${var.environment}"
//    Description = "alb-${var.environment}"
//  })
//}
//
//resource "aws_security_group" "ingress-alb" {
//  name   = "alb-sg"
//  vpc_id = aws_vpc.vpc_k8s.id
//
//  ingress {
//    cidr_blocks = [
//      "${chomp(data.http.myip.body)}/32"
//    ]
//    from_port   = 0
//    to_port     = 22
//    protocol    = "tcp"
//  }
//
//  // Terraform removes the default rule
//  egress {
//    from_port   = 0
//    to_port     = 0
//    protocol    = "-1"
//    cidr_blocks = [
//      "0.0.0.0/0"]
//  }
//
//  tags = merge(local.common_tags,
//  {
//    description = "access-alb"
//  })
//}