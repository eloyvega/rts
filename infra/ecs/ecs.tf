resource "aws_ecs_cluster" "cluster" {
  name = "terraform-managed"

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}