data "template_file" "kubernetes_csr_json" {
  template = file("${path.module}/files/certs/template-kubernetes-csr.json")
  vars     = {
    cert_cn                      = var.cert_cn
    cert_country                 = var.cert_country
    cert_locality                = var.cert_locality
    cert_organisation_name       = var.cert_organisation_name
    cert_organisational_unit     = var.cert_organisational_unit
    cert_state                   = var.cert_state
    kubernetes_public_ip_address = aws_eip.eip.public_ip
    network_ip_controller_1      = var.network_ip_controller_1
    network_ip_controller_2      = var.network_ip_controller_2
    network_ip_etcd_1            = var.network_ip_etcd_1
    network_ip_etcd_2            = var.network_ip_etcd_2
    network_ip_primary_ip        = var.network_ip_primary_ip
    network_ip_worker_1          = var.network_ip_worker_1
    network_ip_worker_2          = var.network_ip_worker_2
  }
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