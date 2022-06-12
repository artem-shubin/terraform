#------------------
# Security group
# launch_configuration with auto ami
# Auto scaling with 2 availability_zone
# Load Balancer with 2 availability_zone


data "aws_availability_zones" "available" {}
data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-*-amd64-server-*"]
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "./modules/vpc"
}
#module "vpc" {
#  source = "./modules/vpc"
#}
resource "aws_launch_configuration" "web" {
  name_prefix     = "aws-"
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.allow_ports.id]
  user_data       = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "allow_ports" {
  name = "allow_ports"

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "allow_ports" })
}

#------------------ aws_autoscaling_group


resource "aws_autoscaling_group" "web" {
  name_prefix               = "ASG-${aws_launch_configuration.web.name}"
  max_size                  = 2
  min_size                  = 1
  health_check_grace_period = 30
  health_check_type         = "ELB"
  desired_capacity          = 2
  load_balancers            = [aws_elb.web.name]
  launch_configuration      = aws_launch_configuration.web.name
  vpc_zone_identifier       = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]

  #  tags = merge(var.common_tags, { Name = "aws_as" })

}

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available.names[1]
}


#------------------aws_elb

resource "aws_elb" "web" {
  name               = "elb-web"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  tags = merge(var.common_tags, { Name = "aws_elb" })
}
