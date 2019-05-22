provider "aws" {
  profile = "test"
  region = "eu-central-1"
}

variable "linux" {
  description = "Linux distrib"
  default = "ubuntu" #"amazon_linux"
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

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.7.0"

  name        = "SKalinin Terraform"
  description = "SKallinin security group for EC2 instance"
  vpc_id      = "${data.aws_vpc.default.id}"
  tags = {
    "Project" = "SKalinin Terraform test"
  }
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp", "ssh-tcp", "winrm-http-tcp", "winrm-https-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = "${module.ec2.id[0]}"
}

module "ec2" {
  source = "../../"

  instance_count = 1

  name                        = "skalinin-terraform"
  tags = {
    "Project" = "SKalinin Terraform test"
  }
  ami                         = "${var.linux == "ubuntu" ? data.aws_ami.ubuntu.id : data.aws_ami.amazon_linux.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  key_name                    = "skalinin"

  root_block_device = [{
    volume_type = "gp2"
    volume_size = 50
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
