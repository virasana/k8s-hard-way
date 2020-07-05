resource "aws_instance" "etcd1" {
  ami                         = var.ec2_ami_type_etcd_node
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = "true"
  key_name                    = var.ec2_ssh_key_name

  vpc_security_group_ids = [
    aws_security_group.ingress-all.id]

  user_data = templatefile("${path.module}/files/init.sh", {
    "network_ip_controller_1" = var.network_ip_controller_1,
    "network_ip_controller_2" = var.network_ip_controller_2,
    "network_ip_etcd_1" = var.network_ip_etcd_1,
    "network_ip_etcd_2" = var.network_ip_etcd_2,
    "network_ip_worker_1" = var.network_ip_worker_1,
    "network_ip_worker_2" = var.network_ip_worker_2
  })

  availability_zone = var.network_availability_zone_a
  subnet_id         = aws_subnet.public_k8s.id
  private_ip        = "10.0.0.245"

  tags = merge(local.common_tags,
  {
    description = "etcd1"
  })
  depends_on = [aws_security_group.ingress-all]
}

resource "aws_instance" "etcd2" {
  ami                         = var.ec2_ami_type_etcd_node
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = "true"
  key_name                    = var.ec2_ssh_key_name

  vpc_security_group_ids = [
    aws_security_group.ingress-all.id]

  user_data = templatefile("${path.module}/files/init.sh", {
    "network_ip_controller_1" = var.network_ip_controller_1,
    "network_ip_controller_2" = var.network_ip_controller_2,
    "network_ip_etcd_1" = var.network_ip_etcd_1,
    "network_ip_etcd_2" = var.network_ip_etcd_2,
    "network_ip_worker_1" = var.network_ip_worker_1,
    "network_ip_worker_2" = var.network_ip_worker_2
  })

  availability_zone = var.network_availability_zone_a
  subnet_id         = aws_subnet.public_k8s.id
  private_ip        = "10.0.0.246"

  tags = merge(local.common_tags,
  {
    description = "etcd2"
  })
  depends_on = [aws_security_group.ingress-all]
}