output "network_elastic_ip_k8s" {
  value = module.dev-k8s-cluster.network_aws_eip
}