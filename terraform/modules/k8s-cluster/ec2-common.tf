resource "aws_key_pair" "ec2" {
  public_key = file("/root/.ssh/id_rsa.pub")

  key_name = "ksone"
  tags     = merge(local.common_tags,
  {
    description = "key-pair-ec2"
  })

}