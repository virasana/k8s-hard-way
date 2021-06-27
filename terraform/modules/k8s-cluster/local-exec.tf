resource "null_resource" "remove-remote-hosts-ssh" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "/tmp/files/utils/cleanup-ssh.sh"
  }
}

resource "null_resource" "setup-local-hosts" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "/tmp/files/hosts/install-local-hosts.sh"
  }
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