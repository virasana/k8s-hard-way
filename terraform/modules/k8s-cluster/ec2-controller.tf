resource "aws_instance" "controller" {
  count                       = var.ec2_count_controller
  ami                         = var.ec2_ami_type_controller_node
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = "true"
  key_name                    = var.ec2_ssh_key_name

  vpc_security_group_ids = [
    aws_security_group.ingress-all.id]

  availability_zone = var.network_availability_zone_a
  subnet_id         = aws_subnet.public_k8s.id
  private_ip        = "${var.network_ip_controller}${count.index}"

  tags = merge(local.common_tags,
  {
    Name        = "controller${count.index}"
    Description = "controller${count.index}"
  })

  depends_on = [
    aws_security_group.ingress-all]
}