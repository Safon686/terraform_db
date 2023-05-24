resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "vpc_for_domain"
    }
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "igw_for_domain"
    }
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Public_subnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone = "eu-central-1b"
  tags = {
    Name = "Private_subnet"
  }
}
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route_teble_public"
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table_public.id
}
