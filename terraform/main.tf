module "networking" {
  source = "./modules/networking"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security" {
  source = "./modules/security"

  project_name     = var.project_name
  vpc_id           = module.networking.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "compute" {
  source = "./modules/compute"

  project_name   = var.project_name
  ami_id         = var.ami_id
  instance_type  = var.instance_type
  key_name       = var.key_name
  subnet_ids     = module.networking.public_subnet_ids
  jenkins_sg_id  = module.security.jenkins_sg_id
  ansible_sg_id  = module.security.ansible_sg_id
}
