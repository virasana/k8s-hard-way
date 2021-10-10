resource "aws_instance" "bastion" {
  ami                         = var.ec2_ami_type_bastion
  instance_type               = var.ec2_instance_type
  associate_public_ip_address = "true"
  key_name                    = var.ec2_ssh_key_name

  vpc_security_group_ids = [
    aws_security_group.ingress-bastion.id]

  availability_zone = var.network_availability_zones[0]
  subnet_id         = aws_subnet.public_k8s.id
  private_ip        = var.network_ip_bastion
  tags              = merge(local.common_tags,
  {
    Name        = "bastion-${var.environment}"
    Description = "bastion-${var.environment}"
  })
  depends_on        = [
    aws_security_group.ingress-all]
}