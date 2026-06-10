# get all the available zones of current region
data "aws_availability_zones" "available" {}

# create VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "main-vpc"
  }
  
}

# create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  
}

# create Public Subnets
resource "aws_subnet" "public" {
  count                    = 3
  vpc_id                   = aws_vpc.main.id
  cidr_block               = var.public_subnet_cidr[count.index]
  availability_zone        = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch  = true
  
  tags = {
    Name = "public-subnet-${count.index +1}"
  }
}

# create public route table
resource "aws_route_table" "public" {
  vpc_id                  = aws_vpc.main.id
  route {
    cidr_block    = "0.0.0.0/0"
    gateway_id    = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public-route-table"
  }
  
}

# attach public subnets to public route table
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
  
}

# create EIP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "nat-gateway-eip"
  }
  
}

# create NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public[0].id # the nat must be put in Public subnets
  tags = {
    Name = "main-nat-gateway"
  }
  depends_on = [aws_internet_gateway.igw]
}

# create private subnets
resource "aws_subnet" "private" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "private-subnet-${count.index +1}"
  }

}

# create private route table
resource "aws_route_table" "private" {
  vpc_id            = aws_vpc.main.id
  tags              = {
    Name = "private-route-table"
  }
}

# add default route to private route table and point to NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id          = aws_route_table.private.id
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = aws_nat_gateway.main.id
  
}

# attach private subnets to private route table
resource "aws_route_table_association" "private" {
  count             = 3
  subnet_id         = aws_subnet.private[count.index].id
  route_table_id    = aws_route_table.private.id

}





