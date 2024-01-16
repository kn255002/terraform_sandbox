###  Creating EC2 Instance.
resource "aws_instance" "example" {
  instance_type = var.instance_type #Hardware
  ami           = var.ami           #OS/Ubuntu 20.04
  tags = {
    name = "EC2-instance"
  }
}
