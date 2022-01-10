
resource "aws_security_group" "jumpsrv" {
  name        = "jumpsrv"
  description = "Allow all inbound traffic for DevOps team"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = var.ingress_cidr_blocks
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

resource "aws_key_pair" "devops" {
  key_name   = "devops-team"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCr+PkDvtVmEY48BvUyg4wGaF7mH5HECRq0+oTPsvLsCAYIwOim1W5jrBxuPNHu13gX6Z2e0XwuRQof1bfaxHtZUMErnomcJNVdm54+3cDaaAEZDOy+xjv1gJDX/hllf+fHz7p4Q43VFZJ4GrxgTnCI+CdlZmejKJhYw0PclkUfGDe5EMd83VDpyc3naAkxy0Pw13YlusQKNeGE695ZfbWBkP/xMqN1DEzhrxPfT1nPMsIlNthc+kWjrdeowAe8/5IMQlTHth062dhxrmYWzYTyQrsOrxEY3zZzKk53vKMgXIuOvh9RLAon6Qf60aRkqYeAzf5ugXA4Ezb/Wdpb4r+gLgSRxw2Z0HzU1+n/++SFwBs6Qfe4dbn84/Q+SdEFZ1G4Rt4xrjFxU7VQ0pD1O1IZx+17mK7H1CovBSc5II2cMSil7kFcsRTGMpwGlRUWbrN2J4aKiQ4rTLROsxkwhtBmYOtgzgMTMnH0kENc59nMN84FC0JA+uE7f65YSXOsvK0="
}

resource "aws_ami_copy" "ubuntu" {
  name              = "ubuntu-encrypted-ami"
  description       = "An encrypted root ami based off ${data.aws_ami.ubuntu.id}"
  source_ami_id     = data.aws_ami.ubuntu.id
  source_ami_region = "ap-southeast-1"
  encrypted         = true

  tags = { Name = "ubuntu-encrypted-ami" }
}
module "ec2_instance" {
  depends_on = [module.vpc]
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = var.instance_name

  ami                    = aws_ami_copy.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.devops.key_name
  monitoring             = true
  vpc_security_group_ids = [ aws_security_group.jumpsrv.id ]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}