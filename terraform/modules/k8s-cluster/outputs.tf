output "ec2_instance_etcd1_ssh_command" {
  value = format("ssh fedora@etcd1 ===> %s", aws_instance.etcd1.public_ip)
}

output "ec2_instance_etcd2_ssh_command" {
  value = format("ssh fedora@etcd2 ===> %s", aws_instance.etcd2.public_ip)
}

output "ec2_instance_controller1_ssh_command" {
  value = format("ssh fedora@controller1 ==> %s", aws_instance.controller1.public_ip)
}

output "ec2_instance_controller2_ssh_command" {
  value = format("ssh fedora@controller2 ===> %s", aws_instance.controller2.public_ip)
}

output "ec2_instance_worker1_ssh_command" {
  value = format("ssh fedora@worker1 ===> %s", aws_instance.worker1.public_ip)
}

output "ec2_instance_worker2_ssh_command" {
  value = format("ssh fedora@worker2 ===> %s", aws_instance.worker2.public_ip)
}

output "ec2_instance_etcd1_public_ip" {
  value = aws_instance.etcd1.public_ip
}

output "ec2_instance_etcd2_public_ip" {
  value = aws_instance.etcd2.public_ip
}

output "ec2_instance_controller1_public_ip" {
  value = aws_instance.controller1.public_ip
}

output "ec2_instance_controller2_public_ip" {
  value = aws_instance.controller2.public_ip
}

output "ec2_instance_worker1_public_ip" {
  value = aws_instance.worker1.public_ip
}

output "network_aws_eip" {
  value = aws_eip.eip
}

output "ec2_instance_worker2_public_ip" {
  value = aws_instance.worker2.public_ip
}

output "local-hosts-file" {
  value = local.hosts_file
}

output "network_elastic_ip_k8s" {
  value = "TODO - create EIP and return the address here"
}