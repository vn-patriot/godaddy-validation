provider "aws" {
    region = "ap-southeast-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"
}

resource "aws_security_group" "hided-validation" {
  name        = "hided-validation"
  description = "Security group for hided validation"
  vpc_id      = "vpc-7e6d4919" #VPC default

  ingress {
    from_port   = 22
    to_port	= 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port  = 80 
    to_port    = 80 
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "web" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "subnet-98754cd1" #Using the default subnet VPC Default
  key_name      = "devops" #My private key
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.hided-validation.id}"]
  user_data = "${data.template_file.user_data.rendered}"

  tags {
    Name = "hided-validation"
  }
}

data "aws_route53_zone" "selected" {
  name         = "hided.io."
  private_zone = false
}

resource "aws_route53_record" "hided-validation" {
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.web.public_ip}"]
}
