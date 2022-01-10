#------------------------------------------------------------------------------
#  ec2/variables.tf
#------------------------------------------------------------------------------



variable "vpc_name"             { default = "test-vpc"      }
     
variable "env"                  { default = "test"          }

variable "project"              { default = "demo"          }
variable "ec_role1"             { default = "app"           }
variable "ec_role2"             { default = "web"           }
variable "key_name"             { default = "devops-team"   }

# This is the software version tag on the AMI (regexp)
#
#       Snapshot        1\.2\.\d+-\d+
#       Release         1\.2\.\d+
#
variable "app_version"              {                                       }
variable "api_stackMinSize"         { default = "1"             			}
variable "api_stackMaxSize"         { default = "1"             			}
variable "api_stackDesiredSize"     { default = "1"             			}
variable "api_instance_type"        { default = "t2.micro"      			}


variable "web_stackMinSize"         { default = "1"             			}
variable "web_stackMaxSize"         { default = "1"             			}
variable "web_stackDesiredSize"     { default = "1"             			}
variable "web_instance_type"        { default = "t2.micro"      			}

# ALB variables


variable "alb_api_is_internal"          { default = true            			}
variable "alb_web_is_internal"          { default = false            			}


variable "ipaddress"                    { default =  "49.37.221.208/32"         }
variable "health_check_path"            { default = "/"	                        }
variable "backend_port"                 { default = 80         	 			    }
variable "aws_lb_listener_arn_http"     { default = "80"                        }
variable "aws_lb_listener_arn_https"    { default = "443"                       }
