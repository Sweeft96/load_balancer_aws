provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = var.region
}

resource "aws_key_pair" "my_key" {
  key_name   = var.key_name
  public_key = var.public_key
}
resource "aws_default_vpc" "default" {}

resource "aws_eip" "HaProxy_IP" { # Create static IP for haproxy server
  instance = aws_instance.My_HaProxy.id
}

resource "aws_instance" "My_Worker" {
  count = 3
  ami = "ami-0a261c0e5f51090b1"
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
  ami = "ami-0a261c0e5f51090b1"
  instance_type = var.instance_type
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
resource "local_file" "hosts_cfg" {
  content = templatefile("./templates/ansible_inventory.tpl",
    {
      haproxy = aws_instance.My_HaProxy.*.public_ip
      workers_public = aws_instance.My_Worker.*.public_ip
    }
  )
  filename = "../ansible/inventory"
}
resource "local_file" "haproxy_cfg" {
  content = templatefile("./templates/haproxy.tpl",
    {
      workers_private = aws_instance.My_Worker.*.private_ip
    }
  )
  filename = "../ansible/haproxy.cfg"
}
