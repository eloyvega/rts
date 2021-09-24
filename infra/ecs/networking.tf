#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------

data "aws_availability_zones" "azs" {
  state = "available"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.cluster_name
  cidr = "10.0.0.0/16"

  azs             = data.aws_availability_zones.azs.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false

  tags = {
    Terraform   = "true"
    Environment = var.cluster_name
  }
}

#--------------------------------------------------------------
# Security Group for EC2 Instances
#--------------------------------------------------------------
resource "aws_security_group" "instance" {
  name        = "${var.cluster_name}-instance"
  description = "Security group for incoming traffic from load balancer"
  vpc_id      = module.vpc.vpc_id
}

# resource "aws_security_group_rule" "allow_traffic_from_alb" {
#   type              = "ingress"
#   security_group_id = aws_security_group.instance.id

#   from_port                = "0"
#   to_port                  = "65535"
#   protocol                 = "tcp"
#   source_security_group_id = aws_security_group.alb.id
# }

resource "aws_security_group_rule" "allow_outbound_traffic_instance" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}