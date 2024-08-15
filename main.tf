# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MyTerraformVPC"
  }
}

# Create a Public Subnet
resource "aws_subnet" "public_subnet" {
  cidr_block = "10.0.0.0/17"
  vpc_id     = aws_vpc.terraform_vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

# Create a Private Subnet
resource "aws_subnet" "private_subnet" {
  cidr_block = "10.0.128.0/17"
  vpc_id     = aws_vpc.terraform_vpc.id
  tags = {
    Name = "PrivateSubnet"
  }
}

# Create an Internet Gateway (IGW)
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "MyIGW"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "PublicRoute"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate the Public Subnet with the Public Route Table
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# Create a Private Route Table (if needed)
resource "aws_route_table" "private_route" {
  vpc_id = aws_vpc.terraform_vpc.id
  tags = {
    Name = "PrivateRoute"
  }
}

# Associate the Private Subnet with the Private Route Table
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route.id
}

# Associate default Nacl to both subnets

# Associate default Nacl to public subnet 
resource "aws_network_acl_association" "PubNaclAssociation" {
  network_acl_id = aws_vpc.terraform_vpc.default_network_acl_id
  subnet_id = aws_subnet.public_subnet.id
}

# Associate default Nacl to private subnet
resource "aws_network_acl_association" "PrivNaclAssociation" {
  network_acl_id = aws_vpc.terraform_vpc.default_network_acl_id
  subnet_id = aws_subnet.private_subnet.id
}





