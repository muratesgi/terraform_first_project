terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.42.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "apache-server" {
  ami             = data.aws_ami.amazon-linux-2.id
  instance_type   = "t2.micro"
  key_name        = "tim"
  count           = 2
  security_groups = ["tf-first-project"]
  user_data = file("create_apache.sh")

  tags = {
    Name = "Terraform ${element(var.mytags, count.index)} Instance"
  }
    provisioner "local-exec" {
      command = "echo ${self.private_ip} >> private_ip.txt"
    }
    provisioner "local-exec" {
      command = "echo ${self.public_ip} >> public_ip.txt"
    }
}

resource "aws_security_group" "tf-project-sg" {
  name = "tf-first-project"

  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
variable "mytags" {
  type    = list(string)
  default = ["First", "Second"]
}

output "mypublicip" {
  value = aws_instance.apache-server[*].public_ip
}