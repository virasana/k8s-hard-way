locals {
  common_tags = {
    environment = var.environment
    aws_region  = var.aws_region
    account     = var.aws_account
    name        = "k8s-hard-way"
  }
}