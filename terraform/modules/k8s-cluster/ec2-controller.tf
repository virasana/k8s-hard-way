resource "aws_instance" "controller1" {
  ami                         = var.ec2_ami_type_controller_node
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
  private_ip        = var.network_ip_controller_1

  tags = merge(local.common_tags,
  {
    description = "controller1"
  })

  depends_on = [aws_security_group.ingress-all]

}

resource "aws_instance" "controller2" {
  ami                         = var.ec2_ami_type_controller_node
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
  private_ip        = "10.0.0.138"

  tags = merge(local.common_tags,
  {
    description = "controller2"
  })
  depends_on = [aws_security_group.ingress-all]
}