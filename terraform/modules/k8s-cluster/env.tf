data "template_file" "setup_local_env_variables" {
  template = file("${path.module}/files/env/setup_local_env_vars.sh.tpl")
  vars = {
    eip=aws_eip.eip.public_ip
  }
}

resource "local_file" "setup_local_env_variables_sh" {
  content         = data.template_file.setup_local_env_variables.rendered
  filename        = "/tmp/k8s-hard-way/env/setup_local_env_vars.sh"
  file_permission = "0700"
}