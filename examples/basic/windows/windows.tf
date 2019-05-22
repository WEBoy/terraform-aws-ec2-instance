data "aws_ami" "windows" {
  #amazon_windows_2019
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
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
