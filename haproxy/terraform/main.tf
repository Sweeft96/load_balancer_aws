provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = var.public_key
}
resource "aws_default_vpc" "default" {}

resource "aws_eip" "HaProxy_IP" {
  instance = aws_instance.My_HaProxy.id
}

resource "aws_eip" "Worker_IP_1" {
  instance = aws_instance.My_Worker[0].id
}

resource "aws_eip" "Worker_IP_2" {
  instance = aws_instance.My_Worker[1].id
}

resource "aws_eip" "Worker_IP_3" {
  instance = aws_instance.My_Worker[2].id
}

resource "aws_instance" "My_Worker" {
  count = 3
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.my_haproxy.id]
  tags = {
    Name = "Worker"
    Owner = "Danil Kuchinskiy"
    Project = "HaProxy"
  }
}

resource "aws_instance" "My_HaProxy" {
  ami = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  key_name = var.key_name
  vpc_security_group_ids = [aws_security_group.my_haproxy.id]
  lifecycle {
    create_before_destroy = true
  }
  tags = {
    Name = "Load_Balancer"
    Owner = "Danil Kuchinskiy"
    Project = "HaProxy"
  }
  depends_on = [aws_instance.My_Worker]
}

resource "aws_security_group" "my_haproxy" {
  name        = "allow_tls"
  vpc_id      = aws_default_vpc.default.id
dynamic "ingress" {
  for_each = ["80", "443","22"]
  content {
    from_port        = ingress.value
    to_port          = ingress.value
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security_Group_For_HaProxy",
  }
}