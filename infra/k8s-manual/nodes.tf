resource "aws_launch_configuration" "nodes" {
  name_prefix          = "k8s_manual_nodes"
  image_id             = data.aws_ami.ubuntu.id
  instance_type        = var.node_instance_type
  key_name             = var.ssh_key_name
  security_groups      = [aws_security_group.node_sg.id]
  user_data            = templatefile("./userdata-nodes.sh", { bucket = aws_s3_bucket.kubeadm_bucket.id })
  iam_instance_profile = aws_iam_instance_profile.k8s_instance_profile.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nodes" {
  name                 = aws_launch_configuration.nodes.name
  max_size             = var.number_of_nodes
  min_size             = var.number_of_nodes
  desired_capacity     = var.number_of_nodes
  launch_configuration = aws_launch_configuration.nodes.name
  vpc_zone_identifier  = module.vpc.public_subnets

  tag {
    key                 = "Name"
    value               = "K8s manual - Node"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "node_sg" {
  name        = "node_sg"
  description = "Allow traffic for nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "All traffic inside VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.1.0.0/16"]
  }

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "NodePort"
    from_port        = 30000
    to_port          = 32767
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ingress {
  #   description      = "Kubelet"
  #   from_port        = 10250
  #   to_port          = 10250
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
