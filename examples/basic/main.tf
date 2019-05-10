provider "aws" {
  profile = "test"
  region = "eu-central-1"
}

##################################################################
# Data sources to get VPC, subnet, security group and AMI details
##################################################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = "${data.aws_vpc.default.id}"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.7.0"

  name        = "SKalinin Terraform"
  description = "SKallinin security group for EC2 instance"
  vpc_id      = "${data.aws_vpc.default.id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = "${module.ec2.id[0]}"
}

module "ec2" {
  source = "../../"

  # instance_count = 2

  name                        = "skalinin-terraform-normal"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  instance_type               = "m4.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true

  root_block_device = [{
    volume_type = "gp2"
    volume_size = 10
  }]
}

# module "ec2_with_t2_unlimited" {
#   source = "../../"
#
#   instance_count = 1
#
#   name                        = "skalinin-example-t2-unlimited"
#   ami                         = "${data.aws_ami.amazon_linux.id}"
#   instance_type               = "t2.micro"
#   cpu_credits                 = "unlimited"
#   subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
#   vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
#   associate_public_ip_address = true
# }
#
# module "ec2_with_t3_unlimited" {
#   source = "../../"
#
#   instance_count = 1
#
#   name                        = "skalinin-example-t3-unlimited"
#   ami                         = "${data.aws_ami.amazon_linux.id}"
#   instance_type               = "t3.large"
#   cpu_credits                 = "unlimited"
#   subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
#   vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
#   associate_public_ip_address = true
# }
