provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami               = data.aws_ami.web_ami.id
  instance_type     = var.instance_type
  availability_zone = var.zone
  key_name          = var.keyname
  count             = var.instancecount
  tags = {
    Name = element(var.ec2name, count.index)
  }

  user_data = <<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd.service
                systemctl enable httpd.service
                echo "Welcome to Terraform ec2 server hosted in  $(hostname -f) " > /var/www/html/index.html
                EOF
}
data "aws_ami" "web_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

variable "instance_type" {}
variable "ec2name" {}
variable "keyname" {}
variable "zone" {}
variable "instancecount" {}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.myec2[*].id

}
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.myec2[*].public_ip
}
