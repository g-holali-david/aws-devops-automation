variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block pour le VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks pour les subnets publics"
  type        = list(string)
}

variable "availability_zones" {
  description = "Zones de disponibilite"
  type        = list(string)
}
