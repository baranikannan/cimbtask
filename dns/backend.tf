terraform {
  backend "s3" {
    region         = "ap-southeast-1"
    bucket         = "cimb-demo-backend"
    key            = "dns/terraform.state"
  }
}