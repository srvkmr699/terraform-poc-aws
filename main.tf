variable "awsprops" {
  type = "map"
  default = {
    region = "ap-south-1"
    vpc = "vpc-5234832d"
    ami = "ami-053b0d53c279acc90"
    itype = "t2.micro"
    subnet = "subnet-81896c8e"
    publicip = true
    keyname = "metyis-tf-instance-key-pair"
    secgroupname = "metyis_ec2_sec_group"
  }
}

provider "aws" {
  region = lookup(var.awsprops, "region")
  access_key = ""
  secret_key = ""
}

resource "aws_security_group" "metyis_ec2_sg" {
  name = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")

  ingress {
    description = "SSH Port"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Http Port"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
    
}

resource "aws_instance" "metyis-ec2-instane" {
  ami = lookup(var.awsprops, "ami")
  instance_type = lookup(var.awsprops, "itype")
  subnet_id = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name = lookup(var.awsprops, "keyname")

  root_block_device {
    delete_on_termination = true
    iops = 150
    volume_size = 50
    volume_type = "gp2"
  }
  tags = {
    Name ="SERVER01"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.metyis_ec2_sg ]
}


output "ec2instance" {
  value = aws_instance.metyis-ec2-instane.public_ip
}
