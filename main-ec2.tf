resource "aws_instance" "example_instance" {
   instance_type  = var.instance_type #Hardware
    ami           = var.ami           #OS/Ubuntu 20.04

  tags = {
    Name = "Kursad Your EC2"
  }
}
