aws_account                      = "624368621157"
aws_region                       = "eu-west-1"
dns_etcd_srv_name                = "etcd"
ec2_ami_type_bastion             = "ami-0a8e758f5e873d1c1"          // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
ec2_ami_type_controller_node     = "ami-0a8e758f5e873d1c1"          // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
ec2_ami_type_etcd_node           = "ami-0a8e758f5e873d1c1"          // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
ec2_ami_type_worker_node         = "ami-0a8e758f5e873d1c1"          // Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
ec2_count_controller             = 3
ec2_count_etcd                   = 3
ec2_count_worker                 = 3
ec2_instance_type                = "t2.nano"
ec2_ssh_key_name                 = "ksone"
environment                      = "ksone"
network_availability_zones       = [ "eu-west-1a", "eu-west-1b", "eu-west-1c" ]
network_ip_alb                   = "10.240.254.10"
network_ip_bastion               = "10.240.254.110"
network_ip_controller_mask       = "10.240.x.11x"
network_ip_worker_mask           = "10.240.x.1x"
network_subnet_count_private     =  3
network_subnet_private_cidr_mask = "10.240.x.0/24"
network_subnet_public_cidr_range = "10.240.254.0/24"
network_vpc_cidr_range           = "10.240.0.0/16"