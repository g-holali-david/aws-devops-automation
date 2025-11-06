variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "vpc_id" {
  description = "ID du VPC"
  type        = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorise pour SSH"
  type        = list(string)
}
