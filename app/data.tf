data "aws_region" "current" { }

variable "suffixes" {
  default = {
    "0" = "a"
    "1" = "b"
    "2" = "c"
  }
}

data "aws_vpc" "main" {
  filter {
    name = "tag:Name"
    values = [ "${var.env}-vpc" ]
  }
}

data "aws_availability_zone" "zones" {
  count = "2"
  name  = "${data.aws_region.current.name}${lookup(var.suffixes, count.index)}"
}

data "aws_subnet" "tier1" {
  count             = 2
  vpc_id            = "${ data.aws_vpc.main.id }"
  availability_zone = "${ element( data.aws_availability_zone.zones.*.id, count.index ) }"

  tags = {
    Tier = "1"
  }
}

data "aws_subnet" "tier2" {
  count             = 2
  vpc_id            = "${ data.aws_vpc.main.id }"
  availability_zone = "${ element( data.aws_availability_zone.zones.*.id, count.index ) }"

  tags = {
    Tier = "2"
  }
}

#------------------------------------------------------------------------------
#   AMI's
#------------------------------------------------------------------------------

# Most recent from the Build account

data "aws_ami" "api" {
  most_recent = true
  owners      = ["945251900491"]

  filter {
    name   = "name"
    values = ["ubuntu-encrypted-ami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#------------------------------------------------------------------------------
#   cloudinit config
#------------------------------------------------------------------------------


# data "template_file" "application_yml" {
#   template = "${file("${path.module}/files/application.yml")}"

#    vars =  {
#     env   = "${var.env}"
    
#   }
# }


# data "template_file" "cloud_config" {
#   template = "${file("${path.module}/files/cloud-config.tpl")}"

#    vars =  {
#     content = "${base64encode( data.template_file.application_yml.rendered )}"
#   }
# }

data "template_file" "cloud_config" {
  template = "${file("${path.module}/files/cloud-config.tpl")}"

  vars = {
#    shellscript = "${base64encode( data.template_file.shellscript.rendered )}"
    app_version = var.app_version

  }
}

# data "template_file" "shellscript" {
#   template = "${file("${path.module}/files/application.sh")}"

#   vars = {
#     app_version   = var.app_version
#   }
# }

data "template_file" "web_config" {
  template = "${file("${path.module}/files/web_config.tpl")}"

  vars = {
    app_version = var.app_version
    nginx_conf = "${base64encode( data.template_file.nginx_conf.rendered )}"
    app_alb_url   = "${aws_alb.api.dns_name}"
  }
}

data "template_file" "nginx_conf" {
  template = "${file("${path.module}/files/reverse-proxy.conf")}"

  vars = {
    app_alb_url   = "${aws_alb.api.dns_name}"
  }
}