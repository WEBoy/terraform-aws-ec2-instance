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
  ingress_rules       = ["all-icmp", "rdp-tcp", "winrm-http-tcp"]
  egress_rules        = ["all-all"]
}

resource "aws_eip" "this" {
  vpc      = true
  instance = "${module.ec2.id[0]}"
}

resource "aws_instance" "this" {
  name = "skalinin-win-t2"
  ami                         = "${data.aws_ami.windows.id}"
  instance_type               = "t2.micro"
  subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true
  key_name                    = "skalinin"
  get_password_data           = "true"

  root_block_device {
   volume_type = “${var.volume_type}”
   volume_size = “${var.volume_size}”
   delete_on_termination = “true”
   }

  tags = {
    "Project" = "SKalinin Windows Terraform test"
  }
}

  module "ec2" {
    source = "../../../"
    instance_count = 1

    name = "skalinin-win-t2"
    ami                         = "${data.aws_ami.windows.id}"
    instance_type               = "t2.micro"
    subnet_id                   = "${element(data.aws_subnet_ids.all.ids, 0)}"
    vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
    associate_public_ip_address = true
    key_name                    = "skalinin"

    tags = {
      "Project" = "SKalinin Windows Terraform test"
    }

  }
