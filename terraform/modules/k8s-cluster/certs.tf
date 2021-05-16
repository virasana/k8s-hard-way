data "template_file" "kubernetes_csr_json" {
  template = file("${path.module}/files/certs/template-kubernetes-csr.json")
  vars     = {
    cert_cn                      = var.cert_cn
    cert_country                 = var.cert_country
    cert_locality                = var.cert_locality
    cert_organisation_name       = var.cert_organisation_name
    cert_organisational_unit     = var.cert_organisational_unit
    cert_state                   = var.cert_state
    dns_etcd_srv_name            = var.dns_etcd_srv_name
    environment                  = var.environment
    kubernetes_public_ip_address = aws_eip.eip.public_ip
    network_ip_controller        = var.network_ip_controller
    network_ip_worker            = var.network_ip_worker
  }
}

resource "local_file" "kubernetes_csr" {
  content         = data.template_file.kubernetes_csr_json.rendered
  filename        = "/tmp/k8s-hard-way/certs/kubernetes-csr.json"
  file_permission = "0700"
}

data "template_file" "ca_csr_json" {
  template = file("${path.module}/files/certs/template-ca-csr.json")
  vars     = {
    cert_cn                  = var.cert_cn
    cert_country             = var.cert_country
    cert_locality            = var.cert_locality
    cert_organisation_name   = var.cert_organisation_name
    cert_organisational_unit = var.cert_organisational_unit
    cert_state               = var.cert_state
  }
}

resource "local_file" "ca_csr" {
  content         = data.template_file.ca_csr_json.rendered
  filename        = "/tmp/k8s-hard-way/certs/ca-csr.json"
  file_permission = "0700"
}