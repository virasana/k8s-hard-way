resource "local_file" "hosts" {
  content  = "${file("/etc/hosts")}\n${local.hosts_file}"
  filename = "/etc/hosts"
}

// keep ssh hosts clean.  without this, we get the 'man-in-the-middle' messages
// because ssh still 'knows' about the old ip addresses
resource "local_file" "cleanup-hosts" {
  content         = <<EOT
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'controller1'
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'controller2'
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'etcd1'
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'etcd2'
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'worker1'
    ssh-keygen -f '/root/.ssh/known_hosts' -R 'worker2'
EOT
  filename        = "/root/scripts/cleanup-ssh.sh"
  file_permission = "0700"
}

resource "local_file" "kubernetes_csr" {
  content         = data.template_file.kubernetes_csr_json.rendered
  filename        = "/tmp/kubernetes-csr.json"
  file_permission = "0700"
}

resource "local_file" "ca_csr" {
  content         = data.template_file.ca_csr_json.rendered
  filename        = "/tmp/ca-csr.json"
  file_permission = "0700"
}

