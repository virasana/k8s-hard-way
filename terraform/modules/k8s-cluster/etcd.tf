//data "template_file" "etcd_service_etcd" {
//  count    = var.ec2_count_etcd
//  template = file("${path.module}/files/etcd/etcd.service")
//  vars     = {
//    dns_etcd_srv_name    = var.dns_etcd_srv_name
//    environment          = var.environment
//    etcd_name            = "etcd${count.index}"
//    etcd_name_etcd1      = "etcd1"
//    internal_ip          = "${var.network_ip_etcd}.1${count.index}"
//    network_ip_etcd_1    = "${var.network_ip_etcd}.11"
//    network_ip_etcd_this = "${var.network_ip_etcd}.1${count.index}"
//  }
//}
//
//resource "local_file" "etcd1_service" {
//  content         = data.template_file.etcd_service_etcd1.rendered
//  filename        = "/tmp/k8s-hard-way/etcd/etcd1/etcd.service"
//  file_permission = "0700"
//}
//
//data "template_file" "etcd_service_etcd2" {
//  template = file("${path.module}/files/etcd/etcd.service")
//  vars     = {
//    dns_etcd_srv_name = var.dns_etcd_srv_name
//    environment       = var.environment
//    etcd_name         = var.etcd_name_etcd2
//    etcd_name_etcd1   = var.etcd_name_etcd1
//    internal_ip       = var.network_ip_etcd_2
//    network_ip_etcd_1 = var.network_ip_etcd_1
//    network_ip_etcd_2 = var.network_ip_etcd_2
//  }
//}
//
//resource "local_file" "etcd2_service" {
//  content         = data.template_file.etcd_service_etcd2.rendered
//  filename        = "/tmp/k8s-hard-way/etcd/etcd2/etcd.service"
//  file_permission = "0700"
//}