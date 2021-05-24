// keep ssh hosts clean.  without this, we get the 'man-in-the-middle' messages
// because ssh still 'knows' about the old ip addresses
resource "local_file" "cleanup-ssh" {
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

resource "local_file" "setup-local-hosts" {
  content         = <<EOT
  echo "===> delete previous hosts file entries"
  awk '!/etcd|worker|controller/' /etc/hosts > /tmp/hosts-tmp
  cat /tmp/hosts-tmp > /etc/hosts
  rm -f /tmp/hosts-tmp
  echo "<=== done!"
  echo "===> updating hosts file"
  echo '${local.hosts_entries}' >> /etc/hosts
  echo "<=== done!"
EOT
  filename        = "/root/scripts/setup-local-hosts.sh"
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

resource "local_file" "etcd_service" {
  content         = data.template_file.etcd_service.rendered
  filename        = "/tmp/ansible/etcd.service"
  file_permission = "0700"
}