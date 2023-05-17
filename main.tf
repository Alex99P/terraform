# providers need to be installed
provider "aws" {
  region = "eu-central-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {} #trebuie sa adaug si adresea de acasa
variable "instance_type" {}
variable "public_key_location" {}


resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
      Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id = aws_vpc.myapp-vpc.id 
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  map_public_ip_on_launch = true
    tags = {
    Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id 
   tags = {
    Name: "${var.env_prefix}-igw"
  }
}
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name: "${var.env_prefix}-rtb"
  }
}

resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}


resource "aws_security_group" "myapp-sg" {
  name="myapp-sg"  
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.my_ip]
  }
  ingress {  # this is for nginx
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
}
tags = {
    Name: "${var.env_prefix}-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # start with and end with
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
# create a key automatically
resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = file(var.public_key_location)
}

resource "aws_instance" "myapp-server" {
  # these two attributes are required
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  associate_public_ip_address = true  # can be accessed from the browser
  key_name = aws_key_pair.ssh-key.key_name
  tags = {
    Name : "${var.env_prefix}-server"
  }
  # it's the entry point script that gets executed on EC2
# user_data = <<EOF
#                  #!/bin/bash
#                  sudo yum update -y && sudo yum install -y docker
#                  systemctl start docker
#                  usermod -aG docker ec2-user
#                  docker run -p 8080:8080 nginx
#               EOF

user_data = file("entry-script.sh")

}


# output "aws_ami" {
#   value = data.aws_ami.latest-amazon-linux-image.id
# }
output "server-ip" {
    value = aws_instance.myapp-server.public_ip
}
