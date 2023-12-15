#provider "aws" {
#region="us-east-1"
#
#}
#

###--1	Creating security group.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  #INGRESS: It exposes HTTP & HTTPS routes from outside the cluster to services within the cluster.
  ingress {
    #description = "HTTP"
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = var.protocol
    cidr_blocks = ["0.0.0.0/0"] #Classless Inter-Domain Routing /All incoming from ANY Ip allowed.
  }
}

###--2	Creating EC2 Instance.
resource "aws_instance" "example" {
  instance_type = "t2.micro"
  ami           = "ami-0fa1ca9559f1892ec"
  vpc_security_group_ids = [aws_security_group.instance.id]
  
  tags = {
    name = "first-tf-instance"
  }
}
output "This_public_ip" {
value = aws_instance.example.public_ip
description = "The public IP address of the web server"
}


