output "aws_availability_zones_name" {
  value = data.aws_availability_zones.available.names[0]
}

output "aws_ami_ubuntu" {
  value = data.aws_ami.ubuntu.id
}

output "web_loadbalancer_url" {
  value = aws_elb.web.dns_name
}

output "ip" {
  value = module.vpc
}
