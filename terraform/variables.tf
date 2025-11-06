variable "aws_region" {
  description = "Region AWS pour le deploiement"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "devops-tp"
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "Zones de disponibilite"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.small"
}

variable "ami_id" {
  description = "AMI ID pour Debian"
  type        = string
  default     = "ami-0f9c27b471bdcd702"
}

variable "key_name" {
  description = "Nom de la cle SSH existante"
  type        = string
  default     = "devops-key"
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorise pour SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
