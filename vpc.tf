resource "random_string" "stack_id" {
  length  = 6
  special = false
  upper   = false
}

resource "aws_vpc" "vpc" {
  cidr_block                       = var.cidr_block
  assign_generated_ipv6_cidr_block = true
  enable_dns_support               = true
  enable_dns_hostnames             = true
  tags = {
    Name = "vpc-${random_string.stack_id.result}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public" {
  vpc_id          = aws_vpc.vpc.id
  cidr_block      = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 0)
  ipv6_cidr_block = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 0)
  tags = {
    Name = "public-${random_string.stack_id.result}"
  }
}

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_rtb" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public_rtb.id
}
