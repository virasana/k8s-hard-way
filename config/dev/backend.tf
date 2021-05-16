terraform {
  backend "s3" {
    bucket = "ksone-k8s-hard-way"
    key    = "k8s-hard-way.tfstate"
    region = "eu-west-1"
  }
}