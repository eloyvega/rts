resource "aws_instance" "master" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = var.ssh_key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.master_sg.id]
  user_data              = templatefile("./userdata-master.sh", { bucket = aws_s3_bucket.kubeadm_bucket.id })
  iam_instance_profile   = aws_iam_instance_profile.k8s_instance_profile.id

  tags = {
    Name = "K8s manual - Control Plane"
  }
}

resource "aws_security_group" "master_sg" {
  name        = "master_sg"
  description = "Allow traffic for master nodes"
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

  # ingress {
  #   description      = "API server"
  #   from_port        = 6443
  #   to_port          = 6443
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  # ingress {
  #   description      = "etcd"
  #   from_port        = 2379
  #   to_port          = 2380
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

output "ssh_connect_master" {
  value = "ssh -i ${aws_instance.master.key_name}.pem ubuntu@${aws_instance.master.public_ip}"
}
