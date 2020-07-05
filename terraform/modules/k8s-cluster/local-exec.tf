resource "null_resource" "remove-remote-hosts-ssh" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "/root/scripts/cleanup-ssh.sh"
  }
  depends_on = [local_file.cleanup-hosts]
}

resource "null_resource" "generate-certs" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/files/certs/generate-certs.sh ${aws_eip.eip.public_ip}"
  }
  depends_on = [data.template_file.ca_csr_json, data.template_file.kubernetes_csr_json]
}

resource "null_resource" "deploy-k8s-client-certs" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "${path.module}/files/certs/deploy-k8s-client-certs.sh"
  }
  depends_on = [null_resource.generate-certs]
}






