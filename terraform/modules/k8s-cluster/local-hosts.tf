locals {
  common_tags = {
    environment = var.environment
    aws_region  = var.aws_region
    account     = var.aws_account
    name        = "k8s-hard-way"
  }

  hosts_entries = <<EOT
${aws_instance.etcd1.public_ip}             etcd1
${aws_instance.etcd2.public_ip}             etcd2
${aws_instance.worker1.public_ip}           worker1
${aws_instance.worker2.public_ip}           worker2
${aws_instance.controller1.public_ip}       controller1
${aws_instance.controller2.public_ip}       controller2
EOT
}

data "template_file" "hosts_local_hosts" {
  template = file("${path.module}/files/hosts/install-local-hosts.sh")
  vars = {
    hosts_entries=local.hosts_entries
  }
}

resource "local_file" "hosts_install_local_hosts" {
  content         = data.template_file.hosts_local_hosts.rendered
  filename        = "/tmp/k8s-hard-way/hosts/install-local-hosts.sh"
  file_permission = "0700"
}

resource "null_resource" "remove-remote-hosts-ssh" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/files/utils/cleanup-ssh.sh"
  }
}

resource "null_resource" "setup-local-hosts" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "/tmp/k8s-hard-way/hosts/install-local-hosts.sh"
  }
  depends_on = [local_file.hosts_install_local_hosts]
}