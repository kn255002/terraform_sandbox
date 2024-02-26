resource "aws_key_pair" "kn-ec2-key-pair" {
  key_name = "kn-ec2-key-pair"
  public_key = file("~/.ssh/id_rsa.pub")
  #file("/var/terraform_sandbox/credentials/id_rsa.pub") # Replace with your public key path
}
##################################################################################################################
resource "aws_security_group" "Ec2-security-group" {
  name = "Ec2-security-group"
  description = "Security group for EC2 instance"
  ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # Allow SSH from globally.
  }
}
##################################################################################################################

resource "aws_instance" "Ec2-instance" {
   instance_type  = var.instance_type #Hardware
    ami           = var.ami           #OS/Ubuntu 20.04
    key_name      = aws_key_pair.kn-ec2-key-pair.key_name
    vpc_security_group_ids = [aws_security_group.Ec2-security-group.id]   # Security group to allow SSH
    associate_public_ip_address = true                                    # By default machine will have its public ip
    count=2
  tags = {
    Name = "KN-Ec2-instance"
  }
  provisioner "remote-exec" {
    inline = [
      #"sudo useradd knazir -c 'Default user by Terraform: ${formatdate("YYYY-MM-DD HH:MM", timestamp())}' -m",
      "sudo useradd knazir -c 'Default user by Terraform.' -m",
    ]
  }
  connection {
  type        = "ssh"
  user        = "ubuntu" # Replace with your AMI's default user.
  private_key = file("~/.ssh/id_rsa")
  host        = self.public_ip
}
}
