terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.12.1"
    }
  }
}

provider "aws" {
  # Configuration options
}


resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Test_VPC"
  }

}


resource "aws_subnet" "prvsubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Priv_Sub"
  }
}

resource "aws_subnet" "pubsubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "Pub_Sub"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "internet-rt" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  
  tags = {
    Name = "inet_rt"
  }
}

resource "aws_route_table_association" "pubsub-associ" {
  subnet_id      = aws_subnet.pubsubnet.id
  route_table_id = aws_route_table.internet-rt.id
}

resource "aws_security_group" "linuxSG" {
  name        = "linuxSG"
  description = "linux sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "linux-SG"
  }
}

resource "aws_instance" "instance" {
  ami                         = "ami-0c6a6b0e75b2b6ce7"
  instance_type               = "t2.micro"
   key_name                    = "linux"
   #vpc_security_group_ids      = ["sg-0884ac39d92e1fffd"]
   #vpc_security_group_name     = "linuxSG"
   #aws_security_group          = ["sg-0884ac39d92e1fffd"]
   vpc_security_group_ids = [aws_security_group.linuxSG.id]
  subnet_id                   = aws_subnet.pubsubnet.id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 10
    delete_on_termination = true
  }

  tags = {
    Name = "linux"
  }
}

#resource "aws_network_interface_sg_attachment" "sg_attachment" {
 # security_group_id    = aws_security_group.linuxSG.id
  #network_interface_id = aws_instance.instance.primary_network_interface_id
#}












  



