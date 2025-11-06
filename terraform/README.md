# Terraform - AWS DevOps Automation

Infrastructure as Code professionnelle pour le projet DevOps.

## 📁 Structure

```
terraform/
├── providers.tf              # Configuration providers
├── variables.tf              # Variables d'entrée
├── data.tf                   # Data sources & locals
├── main.tf                   # Orchestration modules
├── outputs.tf                # Outputs
├── terraform.tfvars.example  # Template configuration
├── modules/
│   ├── network/              # VPC, Subnets, IGW
│   ├── compute/              # EC2, Security Groups
│   └── loadbalancer/         # NLB, ALB
├── templates/                # Templates Terraform
└── scripts/                  # Scripts utilitaires
```

## 🚀 Quick Start

### Prérequis

```bash
# AWS CLI configuré
aws configure

# Créer la clé SSH dans AWS
aws ec2 create-key-pair --key-name devops-key \
  --query 'KeyMaterial' --output text > ~/.ssh/devops-key.pem
chmod 400 ~/.ssh/devops-key.pem
```

### Déploiement

```bash
# Configuration
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Ajuster si nécessaire

# Initialisation
terraform init

# Validation
terraform validate
terraform fmt -recursive

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan
```

### Outputs

```bash
# Tous les outputs
terraform output

# Résumé
terraform output deployment_summary

# DNS spécifiques
terraform output ansible_nlb_dns
terraform output jenkins_alb_dns
```

## 🏗️ Architecture

### Network Module
- VPC avec DNS activé
- 2 Subnets publics (multi-AZ)
- Internet Gateway
- Route Tables

### Compute Module
- 1 Ansible server (t2.small)
- 2 Jenkins servers (t2.medium, configurable)
- 3 Security Groups
- User-data pour Ansible

### Load Balancer Module
- NLB Ansible (port 9100, TCP)
- ALB Jenkins (port 8080, HTTP)
- Target Groups avec health checks
- Listeners configurés

## 🔧 Modules

### Module Network
```hcl
module "network" {
  source = "./modules/network"
  
  project_name       = "aws-devops-automation-dev"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}
```

### Module Compute
```hcl
module "compute" {
  source = "./modules/compute"
  
  vpc_id                 = module.network.vpc_id
  subnet_ids             = module.network.public_subnet_ids
  jenkins_instance_count = 2
}
```

### Module Load Balancer
```hcl
module "loadbalancer" {
  source = "./modules/loadbalancer"
  
  vpc_id               = module.network.vpc_id
  ansible_instance_id  = module.compute.ansible_instance_id
  jenkins_instance_ids = module.compute.jenkins_instance_ids
}
```

## 📊 Variables Importantes

| Variable | Description | Défaut |
|----------|-------------|--------|
| `project_name` | Nom du projet | aws-devops-automation |
| `environment` | Environnement | dev |
| `jenkins_instance_count` | Nombre serveurs Jenkins | 2 |
| `vpc_cidr` | CIDR du VPC | 10.0.0.0/16 |
| `key_name` | Clé SSH AWS | devops-key |

## 🔐 Sécurité

- Security Groups avec règles minimales
- Volumes EBS chiffrés
- SSH limité à votre IP
- Pas de credentials dans le code

## 🧹 Nettoyage

```bash
# Détruire toute l'infrastructure
terraform destroy

# Avec confirmation automatique (attention!)
terraform destroy -auto-approve
```

## 📝 Best Practices

✅ Utiliser des modules réutilisables
✅ Séparer les environnements (dev/prod)
✅ Versionner le code (Git)
✅ Variables centralisées
✅ Outputs documentés
✅ State distant (S3 + DynamoDB) pour la prod
✅ Validation des variables
✅ Tags cohérents

## 🐛 Troubleshooting

### Erreur: Invalid AMI
```bash
# Vérifier les AMI disponibles
aws ec2 describe-images --owners 099720109477 \
  --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy-22.04*"
```

### Erreur: Key pair not found
```bash
# Lister les clés
aws ec2 describe-key-pairs

# Créer la clé
aws ec2 create-key-pair --key-name devops-key
```

### Erreur: IP auto-detection failed
```bash
# Définir manuellement dans terraform.tfvars
allowed_ssh_cidr = ["VOTRE_IP/32"]
```

## 📚 Documentation

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS VPC](https://docs.aws.amazon.com/vpc/)
- [AWS EC2](https://docs.aws.amazon.com/ec2/)
- [AWS Load Balancing](https://docs.aws.amazon.com/elasticloadbalancing/)
