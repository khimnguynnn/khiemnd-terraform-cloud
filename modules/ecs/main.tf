resource "aws_ecs_cluster" "main" {
  name = "${var.tags["Environment"]}-${var.tags["Project"]}-cluster"

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.tags["Project"]}-cluster"
    },
  )
}

resource "aws_ecs_capacity_provider" "asg_capacity_provider" {
  name = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
    }
  }
  tags = var.tags
}

resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = [
    aws_ecs_capacity_provider.asg_capacity_provider.name
  ]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.asg_capacity_provider.name
    weight            = 1
    base              = 1
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "this" {
  key_name   = "${var.tags["Environment"]}-${var.tags["Project"]}-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "private_key" {
  filename        = pathexpand("~/.ssh/my-key.pem")
  content         = tls_private_key.this.private_key_pem
  file_permission = "0400"
}

resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role_policy_attachment" "ecs_instance_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}
resource "aws_security_group" "ecs_sg" {
  name        = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-sg"
  description = "Security group for ECS instances"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-sg"
    },
  )
}
resource "aws_security_group_rule" "ecs_sg_ingress" {
  for_each = toset(var.allowed_ports)

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_sg.id
}

resource "aws_security_group_rule" "ecs_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_sg.id
}

data "template_file" "ecs_user_data" {
  template = file("${path.module}/ecs_user_data.sh")

  vars = {
    cluster_name = aws_ecs_cluster.main.name
  }
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-lt-"
  image_id      = var.ecs_ami
  instance_type = var.ecs_instance_type
  key_name      = aws_key_pair.this.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ecs_sg.id]
  }

  user_data = base64encode(
    templatefile("${path.module}/ecs_user_data.sh", {
      cluster_name = aws_ecs_cluster.main.name
    })
  )

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity    = 1
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = var.private_subnet_cidrs

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  tag {
    key                 = "Name"
    value               = "${var.tags["Environment"]}-${var.tags["Project"]}-ecs-instance"
    propagate_at_launch = true
  }
}

