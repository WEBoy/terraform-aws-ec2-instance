data "aws_ami" "amazon_linux" {
  # Default user for SSH: ec2-user
  most_recent = true
  owners = ["amazon", "786743331197"]

  filter {
    name = "name"
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
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
