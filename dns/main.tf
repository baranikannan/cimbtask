provider "aws" {
  region = "ap-southeast-1"
}

variable "app_version"              {                                       }

data "terraform_remote_state" "demo" {
  backend = "s3"
  config = {
    bucket         = "cimb-demo-backend"
     key           = "env://${var.app_version}/demo/terraform.state"
    region         = "ap-southeast-1"
  }
}

data "aws_route53_zone" "demo" {
  name         = "dhavaprabu.link"
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "demo.dhavaprabu.link"
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.demo.outputs.web_lb_dns_name
    zone_id                = data.terraform_remote_state.demo.outputs.web_lb_zone_id
    evaluate_target_health = true
  }
}