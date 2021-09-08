resource "aws_instance" "vpn" {
  count                  = var.enable_vpn == true ? 1 : 0
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t3.micro"
  key_name               = var.ssh_key_name
  source_dest_check      = false
  user_data              = file("${path.module}/userdata-vpn.sh")
  vpc_security_group_ids = [aws_security_group.vpn_sg[0].id]
  subnet_id              = module.vpc.public_subnets[0]

  tags = {
    "Name" = "K8s VPN"
  }
}

resource "aws_security_group" "vpn_sg" {
  count       = var.enable_vpn == true ? 1 : 0
  name        = "vpn_sg"
  description = "Allow traffic for VPN"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "UDP traffic"
    from_port        = 1025
    to_port          = 65535
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
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
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
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

resource "aws_eip" "eip" {
  count = var.enable_vpn == true ? 1 : 0
  vpc   = true

  instance                  = aws_instance.vpn[0].id
  associate_with_private_ip = aws_instance.vpn[0].private_ip
}

output "ssh_connect_vpn" {
  value = "ssh -i ${aws_instance.vpn[0].key_name}.pem ec2-user@${aws_eip.eip[0].public_ip}"
}

# Configuration after the installation (manual):

/*
sudo pritunl setup-key
sudo pritunl default-password
*/
