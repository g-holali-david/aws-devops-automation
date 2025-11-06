variable "project_name" {
  description = "Nom du projet"
  type        = string
}


# variable "alb_security_group_id" {
#   description = "Security Group ID de l'ALB Jenkins"
#   type        = string
# }

# variable "nlb_security_group_id" {
#   description = "Security Group ID du NLB Ansible"
#   type        = string
# }


variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des subnet IDs"
  type        = list(string)
}

variable "ami_id" {
  description = "ID de l'AMI"
  type        = string
}

variable "key_name" {
  description = "Nom de la clé SSH"
  type        = string
}

variable "ansible_instance_type" {
  description = "Type d'instance Ansible"
  type        = string
}

variable "jenkins_instance_type" {
  description = "Type d'instance Jenkins"
  type        = string
}

variable "jenkins_instance_count" {
  description = "Nombre de serveurs Jenkins"
  type        = number
}

variable "allowed_ssh_cidr" {
  description = "IPs autorisées pour SSH"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}