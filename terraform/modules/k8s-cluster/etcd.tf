data "template_file" "etcd_service_etcd1" {
  template = file("${path.module}/files/etcd/etcd.service")
  vars = {
    etcd_name = var.etcd_name_etcd1
    internal_ip = var.network_ip_etcd_1
    network_ip_etcd_1 = var.network_ip_etcd_1
    network_ip_etcd_2 = var.network_ip_etcd_2
  }
}

resource "local_file" "etcd1_service" {
  content         = data.template_file.etcd_service_etcd1.rendered
  filename        = "/tmp/k8s-hard-way/etcd/etcd1/etcd.service"
  file_permission = "0700"
}

data "template_file" "etcd_service_etcd2" {
  template = file("${path.module}/files/etcd/etcd.service")
  vars = {
    etcd_name = var.etcd_name_etcd2
    internal_ip = var.network_ip_etcd_2
    network_ip_etcd_1 = var.network_ip_etcd_1
    network_ip_etcd_2 = var.network_ip_etcd_2
  }
}

resource "local_file" "etcd2_service" {
  content         = data.template_file.etcd_service_etcd2.rendered
  filename        = "/tmp/k8s-hard-way/etcd/etcd2/etcd.service"
  file_permission = "0700"
}

resource "null_resource" "setup-etcd1" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ETCD_INSTANCE=etcd1 ${path.module}/files/etcd/install-etcd.sh"
  }
  depends_on = [local_file.hosts_install_local_hosts]
}

resource "null_resource" "setup-etcd2" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "ETCD_INSTANCE=etcd2 ${path.module}/files/etcd/install-etcd.sh"
  }
  depends_on = [local_file.hosts_install_local_hosts, null_resource.generate-certs]
}