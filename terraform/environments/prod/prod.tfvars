# Production Environment Configuration

project_name = "aws-devops-automation"
environment  = "prod"

aws_region         = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

vpc_cidr = "10.1.0.0/16"

key_name = "devops-key-prod"

ansible_instance_type  = "t3.medium"
jenkins_instance_type  = "t3.large"
jenkins_instance_count = 3

allowed_ssh_cidr = [] # Configure with specific IPs in production

common_tags = {
  Project     = "aws-devops-automation"
  Environment = "prod"
  ManagedBy   = "Terraform"
  Team        = "devops-team"
  CostCenter  = "engineering"
}
