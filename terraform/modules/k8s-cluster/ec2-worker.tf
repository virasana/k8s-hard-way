resource "aws_instance" "worker" {
  count                       = var.ec2_count_worker
  ami                         = var.ec2_ami_type_worker_node
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = "true"
  key_name                    = var.ec2_ssh_key_name

  vpc_security_group_ids = [
    aws_security_group.subnet_private.id
  ]

  availability_zone = var.network_availability_zones[count.index]
  subnet_id         = aws_subnet.private_k8s[count.index].id
  private_ip        = replace(var.network_ip_worker_mask, "x", count.index)
  tags              = merge(local.common_tags,
  {
    Name        = "worker${count.index}"
    Name = "worker${count.index}"
    Pod-CIDR    = "10.200.${count.index}.0/24"
  })
  depends_on        = [
    aws_security_group.subnet_private
  ]
}