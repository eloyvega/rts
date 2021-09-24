resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

  capacity_providers = ["FARGATE", "FARGATE_SPOT", aws_ecs_capacity_provider.ec2.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 1
    base              = 0
  }

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.ecs_asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = var.cluster_max_size
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "null_resource" "cloudwatch_agent" {
  depends_on = [aws_ecs_cluster.cluster]
  provisioner "local-exec" {
    command = "aws cloudformation create-stack --stack-name CWAgentECS-${var.cluster_name}-${var.region} --template-body \"$(curl -Ls https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/ecs-task-definition-templates/deployment-mode/daemon-service/cwagent-ecs-instance-metric/cloudformation-quickstart/cwagent-ecs-instance-metric-cfn.json)\" --parameters ParameterKey=ClusterName,ParameterValue=${var.cluster_name} ParameterKey=CreateIAMRoles,ParameterValue=True --capabilities CAPABILITY_NAMED_IAM --region ${var.region}"
  }
}