# Terraform VPC Code Structure

## Directory Structure
```
terraform-vpc/
├── main.tf
├── variables.tf
├── outputs.tf
├── terraform.tfvars.example
├── terraform.tfvars (gitignored)
├── versions.tf
├── data.tf
├── locals.tf
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── README.md
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   └── prod/
│       ├── main.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── backend.tf
├── scripts/
│   ├── init.sh
│   ├── plan.sh
│   ├── apply.sh
│   └── destroy.sh
├── .gitignore
├── README.md
└── .github/
    └── workflows/
        ├── terraform-plan.yml
        ├── terraform-apply.yml
        └── terraform-destroy.yml
```

## File Contents

### Root Level Files

#### `main.tf`
```hcl
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment   = var.environment
      Project       = var.project_name
      Owner         = var.owner
      ManagedBy     = "Terraform"
      CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
    }
  }
}

module "vpc" {
  source = "./modules/vpc"

  # VPC Configuration
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  environment          = var.environment
  
  # Availability Zones
  availability_zones   = var.availability_zones
  
  # Subnets
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  
  # NAT Gateway
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  
  # VPC Features
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  
  # Tags
  tags = var.tags
}
```

#### `variables.tf`
```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "owner" {
  description = "Owner of the resources"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}
```

#### `outputs.tf`
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = module.vpc.database_subnet_ids
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = module.vpc.private_route_table_ids
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = module.vpc.database_subnet_group_name
}
```

#### `terraform.tfvars.example`
```hcl
# Copy this file to terraform.tfvars and update values

# General Configuration
aws_region   = "us-west-2"
environment  = "dev"
project_name = "my-project"
owner        = "devops-team"

# VPC Configuration
vpc_name = "my-project-vpc"
vpc_cidr = "10.0.0.0/16"

# Availability Zones
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

# Subnet Configuration
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs  = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
database_subnet_cidrs = ["10.0.21.0/24", "10.0.22.0/24", "10.0.23.0/24"]

# NAT Gateway Configuration
enable_nat_gateway = true
single_nat_gateway = false

# VPC Features
enable_dns_hostnames = true
enable_dns_support   = true

# Additional Tags
tags = {
  CostCenter = "engineering"
  Team       = "infrastructure"
}
```

#### `versions.tf`
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # Backend configuration will be provided via backend config file
    # or command line arguments
  }
}
```

#### `data.tf`
```hcl
# Get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}
```

#### `locals.tf`
```hcl
locals {
  # Common tags for all resources
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Project     = var.project_name
      Owner       = var.owner
      ManagedBy   = "Terraform"
      Region      = data.aws_region.current.name
      Account     = data.aws_caller_identity.current.account_id
    }
  )
  
  # Calculate number of AZs
  az_count = length(var.availability_zones)
  
  # Naming convention
  name_prefix = "${var.project_name}-${var.environment}"
}
```

### VPC Module (`modules/vpc/`)

#### `modules/vpc/main.tf`
```hcl
# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = var.vpc_name
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-${var.availability_zones[count.index]}"
      Type = "Public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-${var.availability_zones[count.index]}"
      Type = "Private"
    }
  )
}

# Database Subnets
resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.database_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-database-${var.availability_zones[count.index]}"
      Type = "Database"
    }
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  domain = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-eip-${count.index + 1}"
    }
  )
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? (var.single_nat_gateway ? 1 : length(var.private_subnet_cidrs)) : 0

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-nat-${count.index + 1}"
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-public-rt"
    }
  )
}

# Private Route Tables
resource "aws_route_table" "private" {
  count = var.enable_nat_gateway ? length(var.private_subnet_cidrs) : 1

  vpc_id = aws_vpc.main.id

  dynamic "route" {
    for_each = var.enable_nat_gateway ? [1] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.main[0].id : aws_nat_gateway.main[count.index].id
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-private-rt-${count.index + 1}"
    }
  )
}

# Database Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-database-rt"
    }
  )
}

# Public Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table Associations
resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = var.enable_nat_gateway ? aws_route_table.private[var.single_nat_gateway ? 0 : count.index].id : aws_route_table.private[0].id
}

# Database Route Table Associations
resource "aws_route_table_association" "database" {
  count = length(var.database_subnet_cidrs)

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.database.id
}

# Database Subnet Group
resource "aws_db_subnet_group" "database" {
  count = length(var.database_subnet_cidrs) > 0 ? 1 : 0

  name       = "${var.vpc_name}-database-subnet-group"
  subnet_ids = aws_subnet.database[*].id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-database-subnet-group"
    }
  )
}
```

#### `modules/vpc/variables.tf`
```hcl
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for database subnets"
  type        = list(string)
  default     = []
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use single NAT Gateway for all private subnets"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in VPC"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
```

#### `modules/vpc/outputs.tf`
```hcl
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = aws_subnet.database[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.main[*].id
}

output "public_route_table_ids" {
  description = "List of public route table IDs"
  value       = [aws_route_table.public.id]
}

output "private_route_table_ids" {
  description = "List of private route table IDs"
  value       = aws_route_table.private[*].id
}

output "database_route_table_id" {
  description = "ID of the database route table"
  value       = aws_route_table.database.id
}

output "database_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = length(aws_db_subnet_group.database) > 0 ? aws_db_subnet_group.database[0].name : null
}
```

### Environment-Specific Configuration

#### `environments/dev/backend.tf`
```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "vpc/dev/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

#### `environments/dev/terraform.tfvars`
```hcl
# Development Environment Configuration
aws_region   = "us-west-2"
environment  = "dev"
project_name = "my-project"
owner        = "devops-team"

# VPC Configuration
vpc_name = "my-project-dev-vpc"
vpc_cidr = "10.0.0.0/16"

# Cost optimization for dev
single_nat_gateway = true

tags = {
  CostCenter = "engineering"
  Team       = "infrastructure"
  AutoShutdown = "enabled"
}
```

### Scripts

#### `scripts/init.sh`
```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-dev}

echo "Initializing Terraform for environment: $ENVIRONMENT"

cd "environments/$ENVIRONMENT"

terraform init \
  -backend-config="bucket=your-terraform-state-bucket" \
  -backend-config="key=vpc/$ENVIRONMENT/terraform.tfstate" \
  -backend-config="region=us-west-2" \
  -backend-config="encrypt=true" \
  -backend-config="dynamodb_table=terraform-state-lock"

echo "Terraform initialized successfully for $ENVIRONMENT"
```

#### `.gitignore`
```gitignore
# Terraform files
*.tfstate
*.tfstate.*
*.tfplan
*.tfplan.*
.terraform/
.terraform.lock.hcl
terraform.tfvars

# Crash log files
crash.log

# Exclude all .tfvars files except example files
*.tfvars
!*.tfvars.example

# Include override files you do wish to add to version control
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
*tfplan*

# Environment files
.env
.env.local
.env.*.local

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db
```

### GitHub Actions Workflow

#### `.github/workflows/terraform-plan.yml`
```yaml
name: Terraform Plan

on:
  pull_request:
    branches: [ main, develop ]
    paths:
      - '**.tf'
      - '**.tfvars'
      - '.github/workflows/terraform-*.yml'

env:
  TF_VERSION: 1.5.0

jobs:
  terraform-plan:
    name: 'Terraform Plan'
    runs-on: ubuntu-latest
    environment: development
    
    strategy:
      matrix:
        environment: [dev, staging]
    
    steps:
    - name: Checkout
      uses: actions/checkout@v3

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v2
      with:
        terraform_version: ${{ env.TF_VERSION }}

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-west-2

    - name: Terraform Init
      run: |
        cd environments/${{ matrix.environment }}
        terraform init

    - name: Terraform Validate
      run: |
        cd environments/${{ matrix.environment }}
        terraform validate

    - name: Terraform Plan
      run: |
        cd environments/${{ matrix.environment }}
        terraform plan -out=tfplan

    - name: Comment PR
      uses: actions/github-script@v6
      if: github.event_name == 'pull_request'
      with:
        script: |
          const fs = require('fs');
          const plan = fs.readFileSync('environments/${{ matrix.environment }}/tfplan', 'utf8');
          const output = `#### Terraform Plan for ${{ matrix.environment }} 📖
          \`\`\`
          ${plan}
          \`\`\`
          *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })
```

## Secrets Management

### Required Secrets for GitHub Actions:
- `AWS_ACCESS_KEY_ID`: AWS access key for Terraform
- `AWS_SECRET_ACCESS_KEY`: AWS secret key for Terraform

### Environment Variables:
- Store sensitive values in GitHub Secrets
- Use separate AWS accounts/roles for different environments
- Implement least privilege access principles

### Backend State Management:
- S3 bucket for state storage with versioning enabled
- DynamoDB table for state locking
- Encrypted state files

## Usage Instructions

1. **Setup:**
   ```bash
   git clone <your-repo>
   cd terraform-vpc
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize:**
   ```bash
   ./scripts/init.sh dev
   ```

3. **Plan:**
   ```bash
   cd environments/dev
   terraform plan
   ```

4. **Apply:**
   ```bash
   terraform apply
   ```

5. **Destroy:**
   ```bash
   terraform destroy
   ```

This structure provides:
- Modular and reusable VPC components
- Environment-specific configurations
- Proper secrets management
- CI/CD integration
- Comprehensive documentation
- Production-ready practices
