provider "aws" {
  region = var.region
}

###--1  Creating security group.
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  #INGRESS: It exposes HTTP & HTTPS routes from outside the cluster to services within the cluster.
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp" #var.protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###--2  Creating EC2 Instance.
resource "aws_instance" "example" {
  instance_type          = var.instance_type #Hardware
  ami                    = var.ami           #OS/Ubuntu 20.04
  vpc_security_group_ids = [aws_security_group.instance.id]

  tags = {
    name = "first-tf-instance"
  }
}
###--3  Creating output variable.
output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP address of the web server"
}
###--4  Creating launch configuration.
resource "aws_launch_configuration" "example" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance.id]
  user_data       = <<-EOF
#!/bin/bash
echo "Hello, World" > index.xhtml
nohup busybox httpd -f -p ${var.server_port} &
EOF

  lifecycle {
    create_before_destroy = true
  }
}
###--5  Creating Auto_SG.
resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnets.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key                 = "Name"
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }
}
###--6  Extracting info about VPC.
data "aws_vpc" "default" {
  default = true
}
###--7  Extracting info about subnets.
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
###--8  Creating ALB (Types: Application|Network|Classic).
resource "aws_lb" "example" {
  name               = "terraform-asg-example"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [aws_security_group.alb.id]
}

###--9  Creating Listner for ALB.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"
  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

###--10 Creating Security group for ALB.
resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  # Allow inbound HTTP requests
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
###--11 Creating Target group from ASG.
resource "aws_lb_target_group" "asg" {
  name     = "terraform-asg-example"
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

###--12 Creating Listener rule for above created listner.
resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

###--13 Creating output variable
output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "The domain name of the load balancer"
}









#module "EC2_instances" {
#source = "./modules/EC2/"
#}

