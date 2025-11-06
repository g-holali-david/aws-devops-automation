variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "ami_id" {
  description = "AMI ID pour les instances"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
}

variable "key_name" {
  description = "Nom de la cle SSH"
  type        = string
}

variable "subnet_ids" {
  description = "IDs des subnets"
  type        = list(string)
}

variable "jenkins_sg_id" {
  description = "ID du security group Jenkins"
  type        = string
}

variable "ansible_sg_id" {
  description = "ID du security group Ansible"
  type        = string
}
