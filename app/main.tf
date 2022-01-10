provider "aws" {
  region = "ap-southeast-1"
}


locals {
  app_version = try(
    [tostring(var.app_version)]
  )
}