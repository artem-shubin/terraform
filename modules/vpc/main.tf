/*
1) VPC
2) INTERNET GATEWAY
3) XX PUBLIC subnet, route table, rt associations
4) XX PRIVATE subnet, route table, rt associations
5) XX NAT GATEWAY
*/

# VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

# internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}


# XX PUBLIC subnet, route table, rt associations
data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = length(var.public_ip)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_ip, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_public"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_ip)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# XX PRIVATE subnet, route table, rt associations

resource "aws_subnet" "private" {
  count             = length(var.private_ip)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_ip, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route_private"
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_ip)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

# XX NAT GATEWAY
resource "aws_eip" "eip" {
  count = length(var.private_ip)
  vpc   = true
}

resource "aws_nat_gateway" "example" {
  count         = length(var.private_ip)
  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = element(aws_subnet.public[*].id, count.index)
}
# aws vpc endpoint to s3
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-3.ec2"
  vpc_endpoint_type = "Interface"
  tags = {
    Environment = "aws_vpc_endpoint_s3"
  }
}
