resource "aws_route53_zone" "k8s" {
  name  = var.environment
  vpc {
    vpc_id = aws_vpc.vpc_k8s.id
  }
  tags  = merge(local.common_tags,
  {
    Name        = var.environment
    Description =  var.environment
  })
}

resource "aws_route53_record" "controller" {
  count   = var.ec2_count_controller
  zone_id = aws_route53_zone.k8s.id
  name    = "controller${count.index}.${var.environment}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.controller[count.index].private_ip]
}

resource "aws_route53_record" "worker" {
  count   = var.ec2_count_worker
  zone_id = aws_route53_zone.k8s.id
  name    = "worker${count.index}.${var.environment}"
  type    = "A"
  ttl     = "300"
  records = [aws_instance.worker[count.index].private_ip]
}