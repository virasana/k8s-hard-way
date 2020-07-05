output "ec2_instance_etcd1_ssh_command" {
  value = format("ssh fedora@etcd1 ===> %s", module.dev-k8s-cluster.ec2_instance_etcd1_ssh_command)
}

output "ec2_instance_etcd2_ssh_command" {
  value = format("ssh fedora@etcd2 ===> %s", module.dev-k8s-cluster.ec2_instance_etcd2_ssh_command)
}

output "ec2_instance_controller1_ssh_command" {
  value = format("ssh fedora@controller1 ==> %s", module.dev-k8s-cluster.ec2_instance_controller1_ssh_command)
}

output "ec2_instance_controller2_ssh_command" {
  value = format("ssh fedora@controller2 ===> %s", module.dev-k8s-cluster.ec2_instance_controller2_ssh_command)
}

output "ec2_instance_worker1_ssh_command" {
  value = format("ssh fedora@worker1 ===> %s", module.dev-k8s-cluster.ec2_instance_worker1_ssh_command)
}

output "ec2_instance_worker2_ssh_command" {
  value = format("ssh fedora@worker2 ===> %s", module.dev-k8s-cluster.ec2_instance_worker2_ssh_command)
}

output "local-hosts-file" {
  value = module.dev-k8s-cluster.local-hosts-file
}

output "network_elastic_ip_k8s" {
  value = module.dev-k8s-cluster.network_aws_eip
}