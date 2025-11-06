# ========================================
# Module Network (VPC, Subnets, IGW)
# ========================================
module "network" {
  source = "./modules/network"

  project_name       = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  common_tags        = local.common_tags
}

# ========================================
# Module Compute (EC2 Instances)
# ========================================
module "compute" {
  source = "./modules/compute"
  project_name           = local.name_prefix
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.public_subnet_ids
  ami_id                 = data.aws_ami.ubuntu.id
  key_name               = var.key_name
  ansible_instance_type  = var.ansible_instance_type
  jenkins_instance_type  = var.jenkins_instance_type
  jenkins_instance_count = var.jenkins_instance_count
  allowed_ssh_cidr       = local.ssh_allowed_cidr
  common_tags            = local.common_tags
}

# ========================================
# Module Load Balancer
# ========================================
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name  = local.name_prefix
  vpc_id        = module.network.vpc_id
  subnet_ids    = module.network.public_subnet_ids
  common_tags   = local.common_tags

  # Variables pour les instances
  ansible_instance_id  = module.compute.ansible_instance_id
  jenkins_instance_ids = module.compute.jenkins_instance_ids

  # Security Groups des instances
  instance_security_group_ids = [
    module.compute.ansible_sg_id,
    module.compute.jenkins_sg_id
  ]
}

# ========================================
# Génération des fichiers de configuration
# ========================================
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    ansible_ip      = module.compute.ansible_public_ip
    jenkins_servers = module.compute.jenkins_instances
    key_name        = var.key_name
  })
  
  filename = "${path.module}/../ansible/inventory/hosts.ini"
}

resource "local_file" "prometheus_config" {
  content = templatefile("${path.module}/templates/prometheus.tftpl", {
    ansible_nlb_dns = module.loadbalancer.nlb_dns_name
    jenkins_servers = module.compute.jenkins_instances
    jenkins_alb_dns = module.loadbalancer.alb_dns_name
  })
  
  filename = "${path.module}/../monitoring/prometheus.yml"
}