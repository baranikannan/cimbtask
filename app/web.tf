#------------------------------------------------------------------------------
#   Security Groups
#------------------------------------------------------------------------------

resource "aws_security_group" "webalb" {
  name_prefix = "${var.env}-${var.ec_role2}-alb-${var.app_version}"
  description = "${var.env} ${var.project} ${var.ec_role2}  ALB ${var.app_version}"
  vpc_id      = "${data.aws_vpc.main.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.ipaddress}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project}-${var.ec_role2}-alb-${var.app_version}"
    Application = "${var.ec_role2}"
    Role        = "${var.ec_role2}"
    Environment = "${var.env}"
  }
}


resource "aws_security_group" "websrv" {
  name_prefix = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  description = "${var.env} ${var.project}  ${var.ec_role2}-${var.app_version}"
  vpc_id      = "${data.aws_vpc.main.id}"

  tags = {
    Name        = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
    Environment = "${var.env}"
    Application = "${var.project}"
    Role        = "${var.ec_role2}"
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.webalb.id}"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["sg-0f042a9b6f495049f"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#------------------------------------------------------------------------------
#   Roles, Profiles and Policies
#------------------------------------------------------------------------------


data "aws_iam_policy_document" "web_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web" {
  name_prefix        = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  path               = "/"
  assume_role_policy = "${data.aws_iam_policy_document.web_role.json}"
}

resource "aws_iam_instance_profile" "web" {
  name_prefix = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  path        = "/"
  role        = "${aws_iam_role.web.name}"
}

data "aws_iam_policy_document" "web_policy" {
  statement {
    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:PutMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics"
    ]

    resources = [
      "*",
    ]
  }

}

resource "aws_iam_policy" "web" {
  name_prefix = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  path        = "/"
  description = "${var.env} ${var.project} policy"
  policy      = "${data.aws_iam_policy_document.web_policy.json}"
}

resource "aws_iam_role_policy_attachment" "web" {
  role       = "${aws_iam_role.web.name}"
  policy_arn = "${aws_iam_policy.web.arn}"
}



#------------------------------------------------------------------------------
#   ALB
#------------------------------------------------------------------------------

resource "aws_alb" "web" {
  name            = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  subnets         = data.aws_subnet.tier1.*.id
  security_groups = ["${aws_security_group.webalb.id}"]
  internal        = "${var.alb_web_is_internal}"

  tags = {
    Name        = "${var.env}-${var.project}-${var.ec_role2}-ALB-${var.app_version}"
    Environment = "${var.env}"
    Application = "${var.project}"
    Role        = "${var.ec_role2}"
  }
}


resource "aws_alb_target_group" "web_target_group" {
  name                 = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  vpc_id               =  data.aws_vpc.main.id
  port                 = "${var.backend_port}"
  protocol             = "HTTP"

  health_check {
    interval            = "10"
    path                = "${var.health_check_path}"
    port                = "traffic-port"
    healthy_threshold   = "3"
    unhealthy_threshold = "5"
    timeout             = "5"
    protocol            = "HTTP"
    matcher             = "200-299"
  }

  tags = {
    Name        = "${var.env}-${var.project}-${var.ec_role2}-ALB-${var.app_version}"
    Environment = "${var.env}"
    Application = "${var.project}"
    Role        = "${var.ec_role2}"
  }

}

resource "aws_alb_listener" "web_frontend_http" {
  load_balancer_arn = "${aws_alb.web.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_target_group.arn}"
    type             = "forward"
  }

}


#------------------------------------------------------------------------------
# Launch Config
#------------------------------------------------------------------------------

resource "aws_launch_configuration" "web" {
  name_prefix                 = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
  image_id                    = data.aws_ami.api.id
  instance_type               = "${var.web_instance_type}"
  associate_public_ip_address = "false"
  key_name                    = "${var.key_name}"
  iam_instance_profile        = "${aws_iam_instance_profile.web.name}"
  security_groups             = [ "${aws_security_group.websrv.id}"]
  user_data                   = "${data.template_file.web_config.rendered}"

  root_block_device {
    volume_size = 20
  }

  lifecycle {
    create_before_destroy = true
  }
}

#------------------------------------------------------------------------------
# Autoscaling group
#------------------------------------------------------------------------------

resource "aws_autoscaling_group" "web" {
  name_prefix           = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"

  min_size              = "${var.web_stackMinSize}"
  max_size              = "${var.web_stackMaxSize}"
  vpc_zone_identifier   =  data.aws_subnet.tier2.*.id
  launch_configuration  = "${aws_launch_configuration.web.name}"
  desired_capacity      = "${ var.web_stackDesiredSize }"
  target_group_arns        = [ "${aws_alb_target_group.web_target_group.arn}" ]
  health_check_type     = "ELB"

  enabled_metrics       = [
                            "GroupMinSize",
                            "GroupMaxSize",
                            "GroupDesiredCapacity",
                            "GroupInServiceInstances",
                            "GroupPendingInstances",
                            "GroupStandbyInstances",
                            "GroupTerminatingInstances",
                            "GroupTotalInstances"
                          ]

  tag {
    key                 = "Name"
    value               = "${var.env}-${var.project}-${var.ec_role2}-${var.app_version}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Environment"
    value               = "${var.env}"
    propagate_at_launch = true
  }
  tag {
    key                 = "Application"
    value               = "${var.project}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}