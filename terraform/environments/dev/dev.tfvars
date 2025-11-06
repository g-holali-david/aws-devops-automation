# Development Environment Configuration

project_name = "aws-devops-automation"
environment  = "dev"

aws_region         = "eu-west-1"
availability_zones = ["eu-west-1a", "eu-west-1b"]

vpc_cidr = "10.0.0.0/16"

key_name = "devops-key"

ansible_instance_type  = "t2.small"
jenkins_instance_type  = "t2.medium"
jenkins_instance_count = 2

allowed_ssh_cidr = []

common_tags = {
  Project     = "aws-devops-automation"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Team        = "devops-team"
}
