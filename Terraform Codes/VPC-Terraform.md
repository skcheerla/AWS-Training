Infrastructure Components:
VPC Setup:

1 VPC with CIDR 10.0.0.0/16
Spans across 3 Availability Zones automatically

Subnets:

3 Public subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
3 Private subnets (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)
One subnet per AZ for both public and private

Networking:

Internet Gateway for public internet access
3 NAT Gateways (one per AZ) for private subnet internet access
Proper route tables and associations

EC2 Instances:

3 instances in public subnets (one per AZ)
3 instances in private subnets (one per AZ)
All instances run Amazon Linux 2 with Apache web server

To Use This Configuration:

Prerequisites:
bash# Install Terraform
# Configure AWS CLI with proper credentials
aws configure

Prepare SSH Key:
bash# Generate SSH key pair if you don't have one
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa

Deploy:
bash# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

Customize Variables:
You can create a terraform.tfvars file to customize:
hclregion = "us-east-1"
vpc_cidr = "10.0.0.0/16"
project_name = "my-project"
instance_type = "t3.small"


Key Features:

High Availability: Resources distributed across 3 AZs
Security: Private instances only accessible from public subnets
Internet Access: Public instances have direct internet access, private instances use NAT Gateways
Web Servers: All instances come with Apache pre-installed showing their AZ information
Scalable: Easy to modify instance counts or types

The configuration will output all important resource IDs and IP addresses after deployment, making it easy to connect to and manage your instances.RetryClaude does not have the ability to run the code it generates yet.Claude can make mistakes. Please double-check responses. Sonnet 4
