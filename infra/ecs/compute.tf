#--------------------------------------------------------------
# Launch Configuration
#--------------------------------------------------------------
data "aws_ami" "ecs_optimized_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }
  owners = ["amazon"]
}

resource "aws_launch_configuration" "ecs_launch_configuration" {
  name_prefix          = var.cluster_name
  image_id             = data.aws_ami.ecs_optimized_ami.image_id
  instance_type        = var.instance_type
  security_groups      = [aws_security_group.instance.id]
  user_data            = templatefile("${path.module}/files/user-data.sh.tpl", { cluster_name = var.cluster_name })
  key_name             = var.key_name == "" ? null : var.key_name
  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.arn

  lifecycle {
    create_before_destroy = true
  }
}

#--------------------------------------------------------------
# Auto Scaling Group
#--------------------------------------------------------------
resource "aws_autoscaling_group" "ecs_asg" {
  name                 = aws_launch_configuration.ecs_launch_configuration.name
  launch_configuration = aws_launch_configuration.ecs_launch_configuration.id
  vpc_zone_identifier  = module.vpc.public_subnets

  # ECS cluster auto scaling will take care of this
  min_size         = 0
  max_size         = var.cluster_max_size
  desired_capacity = 0

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes = [desired_capacity]
  }
}