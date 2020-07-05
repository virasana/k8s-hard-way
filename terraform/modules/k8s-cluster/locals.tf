locals {
  common_tags = {
    environment = var.environment
    aws_region  = var.aws_region
    account     = var.aws_account
    name        = "k8s-hard-way"
  }
  
  hosts_file = <<EOT
${aws_instance.etcd1.public_ip}             etcd1
${aws_instance.etcd2.public_ip}             etcd2
${aws_instance.worker1.public_ip}           worker1
${aws_instance.worker2.public_ip}           worker2
${aws_instance.controller1.public_ip}       controller1
${aws_instance.controller2.public_ip}       controller2
EOT
}