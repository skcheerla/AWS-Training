# Variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "multi-az-vpc"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public Subnets (3 AZs)
resource "aws_subnet" "public" {
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

# Private Subnets (3 AZs)
resource "aws_subnet" "private" {
  count = 3

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    Type = "Private"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = 3

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-eip-${count.index + 1}"
  }
}

# NAT Gateways (one per AZ)
resource "aws_nat_gateway" "main" {
  count = 3

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Tables for Private Subnets (one per AZ)
resource "aws_route_table" "private" {
  count = 3

  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-private-rt-${count.index + 1}"
  }
}

# Route Table Associations - Public
resource "aws_route_table_association" "public" {
  count = 3

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Table Associations - Private
resource "aws_route_table_association" "private" {
  count = 3

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Group for Public EC2 instances
resource "aws_security_group" "public_ec2" {
  name        = "${var.project_name}-public-ec2-sg"
  description = "Security group for public EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-public-ec2-sg"
  }
}

# Security Group for Private EC2 instances
resource "aws_security_group" "private_ec2" {
  name        = "${var.project_name}-private-ec2-sg"
  description = "Security group for private EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from public subnets"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.public_ec2.id]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-private-ec2-sg"
  }
}

# Key Pair (you'll need to create this or reference existing one)
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/id_rsa.pub") # Update path to your public key

  tags = {
    Name = "${var.project_name}-key"
  }
}

# EC2 Instances in Public Subnets (3 instances, one per AZ)
resource "aws_instance" "public" {
  count = 3

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.public_ec2.id]
  subnet_id              = aws_subnet.public[count.index].id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Public Server ${count.index + 1} - AZ: ${data.aws_availability_zones.available.names[count.index]}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-public-ec2-${count.index + 1}"
    Type = "Public"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

# EC2 Instances in Private Subnets (3 instances, one per AZ)
resource "aws_instance" "private" {
  count = 3

  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.private_ec2.id]
  subnet_id              = aws_subnet.private[count.index].id

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Private Server ${count.index + 1} - AZ: ${data.aws_availability_zones.available.names[count.index]}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "${var.project_name}-private-ec2-${count.index + 1}"
    Type = "Private"
    AZ   = data.aws_availability_zones.available.names[count.index]
  }
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_instance_ids" {
  description = "IDs of public EC2 instances"
  value       = aws_instance.public[*].id
}

output "private_instance_ids" {
  description = "IDs of private EC2 instances"
  value       = aws_instance.private[*].id
}

output "public_instance_ips" {
  description = "Public IP addresses of public EC2 instances"
  value       = aws_instance.public[*].public_ip
}

output "private_instance_ips" {
  description = "Private IP addresses of private EC2 instances"
  value       = aws_instance.private[*].private_ip
}

output "nat_gateway_ips" {
  description = "Public IP addresses of NAT Gateways"
  value       = aws_eip.nat[*].public_ip
}

output "availability_zones" {
  description = "Availability zones used"
  value       = data.aws_availability_zones.available.names
}
