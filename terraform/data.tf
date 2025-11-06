# Récupération IP publique (IPv4 uniquement)
data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com/"
}

# AMI Ubuntu 22.04 LTS
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Locales
locals {
  # Nettoyer et valider l'IP
  raw_ip = trimspace(data.http.my_ip.response_body)
  
  # Regex pour valider IPv4
  ipv4_regex = "^([0-9]{1,3}\\.){3}[0-9]{1,3}$"
  is_valid_ipv4 = can(regex(local.ipv4_regex, local.raw_ip))
  
  # IP finale avec fallback si invalide
  my_ip = local.is_valid_ipv4 ? "${local.raw_ip}/32" : "0.0.0.0/0"
  
  ssh_allowed_cidr = length(var.allowed_ssh_cidr) > 0 ? var.allowed_ssh_cidr : [local.my_ip]
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Terraform   = "true"
    }
  )
}