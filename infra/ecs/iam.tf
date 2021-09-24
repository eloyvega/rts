#--------------------------------------------------------------
# IAM Role and Instance Profile for EC2 instances
#--------------------------------------------------------------
data "aws_iam_policy_document" "tust_policy_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${var.cluster_name}-ecsInstanceRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.tust_policy_ec2.json
}

data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = aws_iam_role.ecs_instance_role.name
  role = aws_iam_role.ecs_instance_role.name
}

#--------------------------------------------------------------
# ECS Task Execution Role
#--------------------------------------------------------------
data "aws_iam_policy_document" "trust_policy_ecs_task" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.cluster_name}-ecsTaskExecutionRole"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.trust_policy_ecs_task.json
}

data "aws_iam_policy" "AmazonECSTaskExecutionRolePolicy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = data.aws_iam_policy.AmazonECSTaskExecutionRolePolicy.arn
}

#--------------------------------------------------------------
# Service Role for ECS
#--------------------------------------------------------------
data "aws_iam_role" "AWSServiceRoleForECS" {
  name = "AWSServiceRoleForECS"
}