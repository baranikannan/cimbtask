vpc_name = "test-vpc"
vpc_cidr = "172.168.0.0/19"
vpc_azs = ["ap-southeast-1a", "ap-southeast-1b", "ap-southeast-1c"]
vpc_private_subnets = ["172.168.0.0/22", "172.168.4.0/22", "172.168.8.0/22"]
vpc_public_subnets = ["172.168.12.0/22", "172.168.16.0/22", "172.168.20.0/22"]
vpc_enable_nat_gateway = true
vpc_tags = {
    Terraform   = "true"
    Environment = "test"
  }
  private_subnet_tags = {
    Terraform   = "true"
    Environment = "test"
    Tier        = "2"
    subnet      = "private"

  }
  public_subnet_tags = {
    Terraform   = "true"
    Environment = "test"
    Tier        = "1"
    subnet      = "private"

  }

  #

instance_name           = "jenkins-jump"
instance_type           = "t2.micro"

ingress_cidr_blocks = ["49.37.221.208/32"]