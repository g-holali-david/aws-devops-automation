variable "project_name" {
  description = "Nom du projet"
  type        = string
  default = "aws-devops"
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "subnet_ids" {
  description = "Liste des subnet IDs"
  type        = list(string)
}

variable "ansible_instance_id" {
  description = "ID de l'instance Ansible"
  type        = string
}

variable "jenkins_instance_ids" {
  description = "Liste des IDs des instances Jenkins"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}

variable "instance_security_group_ids" {
  description = "Liste des Security Group IDs des instances"
  type        = list(string)
}
