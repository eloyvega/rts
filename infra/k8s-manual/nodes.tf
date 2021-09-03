resource "aws_instance" "node" {
  count                  = var.number_of_nodes
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.node_instance_type
  key_name               = var.ssh_key_name
  subnet_id              = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))
  vpc_security_group_ids = [aws_security_group.node_sg.id]
  user_data              = file("./userdata-nodes.sh")

  tags = {
    Name = "K8s manual - node ${count.index}"
  }
}

resource "aws_security_group" "node_sg" {
  name        = "node_sg"
  description = "Allow traffic for nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "SSH from anywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "Kubelet"
    from_port        = 10250
    to_port          = 10250
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

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

output "ssh_connect_nodes" {
  value = [for i in aws_instance.node : "ssh -i ${i.key_name}.pem ubuntu@${i.public_ip}"]
}