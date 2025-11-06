variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "aws-devops"
}

variable "environment" {
  description = "Environnement (dev, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"  # ← Changé de eu-west-1 à us-east-1
}

variable "vpc_cidr" {
  description = "CIDR du VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Liste des AZs"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]  # ← Changé pour us-east-1
}

variable "key_name" {
  description = "Nom de la clé SSH AWS"
  type        = string
  default     = "devops-key"  # ← Ajout d'une valeur par défaut cohérente
}

variable "ansible_instance_type" {
  description = "Type d'instance Ansible"
  type        = string
  default     = "t2.small"
}

variable "jenkins_instance_type" {
  description = "Type d'instance Jenkins"
  type        = string
  default     = "t2.medium"
}

variable "jenkins_instance_count" {
  description = "Nombre de serveurs Jenkins"
  type        = number
  default     = 2

  validation {
    condition     = var.jenkins_instance_count >= 1 && var.jenkins_instance_count <= 5
    error_message = "Le nombre doit être entre 1 et 5"
  }
}

variable "allowed_ssh_cidr" {
  description = "Liste des CIDR autorisés pour SSH (vide = auto-detect)"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Tags communs à toutes les ressources"
  type        = map(string)
  default = {
    Project   = "aws-devops"
    ManagedBy = "Terraform"
  }
}