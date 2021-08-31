resource "aws_instance" "master" {
  count                  = 1
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.ssh_key_name
  subnet_id              = element(module.vpc.public_subnets, 3 % length(module.vpc.public_subnets))
  vpc_security_group_ids = [aws_security_group.master_sg.id]

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