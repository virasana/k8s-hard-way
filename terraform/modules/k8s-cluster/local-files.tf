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

resource "local_file" "etcd_service_etcd1" {
  content         = data.template_file.etcd_service_etcd1.rendered
  filename        = "/tmp/ansible/etcd1.service"
  file_permission = "0700"
}

resource "local_file" "etcd_service_etcd2" {
  content         = data.template_file.etcd_service_etcd2.rendered
  filename        = "/tmp/ansible/etcd2.service"
  file_permission = "0700"
}