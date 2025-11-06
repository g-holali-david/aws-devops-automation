variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block du VPC"
  type        = string
}

variable "availability_zones" {
  description = "Liste des availability zones"
  type        = list(string)
}

variable "common_tags" {
  description = "Tags communs"
  type        = map(string)
  default     = {}
}