variable "aws_account" {}
variable "aws_region" {}
variable "dns_etcd_srv_name" {}
variable "ec2_ami_type_bastion" {}
variable "ec2_ami_type_controller_node" {}
variable "ec2_ami_type_etcd_node" {}
variable "ec2_ami_type_worker_node" {}
variable "ec2_count_controller" {}
variable "ec2_count_etcd" {}
variable "ec2_count_worker" {}
variable "ec2_instance_type" {}
variable "ec2_ssh_key_name" {}
variable "environment" {}
variable "network_availability_zones" {}
variable "network_ip_alb" {}
variable "network_ip_bastion" {}
variable "network_ip_controller_mask" {}
variable "network_ip_worker_mask" {}
variable "network_subnet_count_private" {}
variable "network_subnet_private_cidr_mask" {}
variable "network_subnet_public_cidr_range" {}
variable "network_vpc_cidr_range" {}