data "aws_ami" "ubuntu" {
  # Default user for SSH: ubuntu
  most_recent = "true"
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
      name = "owner-alias"
      values = ["amazon"]
  }
}
