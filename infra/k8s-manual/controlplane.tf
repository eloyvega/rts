resource "aws_instance" "master" {
  count                  = var.number_of_masters
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.master_instance_type
  key_name               = var.ssh_key_name
  subnet_id              = element(module.vpc.public_subnets, count.index % length(module.vpc.public_subnets))
  vpc_security_group_ids = [aws_security_group.master_sg.id]
  user_data              = file("./userdata-master.sh")

  tags = {
    Name = "K8s manual - control plane ${count.index}"
  }
}

resource "aws_security_group" "master_sg" {
  name        = "master_sg"
  description = "Allow traffic for master nodes"
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
    description      = "API server"
    from_port        = 6443
    to_port          = 6443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "etcd"
    from_port        = 2379
    to_port          = 2380
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

output "ssh_connect_master" {
  value = [for i in aws_instance.master : "ssh -i ${i.key_name}.pem ubuntu@${i.public_ip}"]
}