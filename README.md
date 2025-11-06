# AWS DevOps Automation

Projet TP : Infrastructure AWS avec Terraform, Ansible, Jenkins et monitoring Prometheus/Grafana.

## 🏗️ Architecture

- **VPC**: aws-devops-automation-vpc
- **Instances**: 1 Ansible + 2 Jenkins (configurable)
- **Load Balancers**: 
  - NLB Ansible (port 9100 - Node Exporter)
  - ALB Jenkins (port 8080 - Jenkins UI)
- **Monitoring**: Prometheus + Grafana (WSL)

## 🚀 Quick Start

```bash
# 1. Déployer infrastructure
cd terraform/
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

# 2. Configurer avec Ansible
cd ../ansible/
ansible all -m ping
ansible-playbook playbooks/site.yml

# 3. Monitoring (WSL)
cd ../monitoring/
# Suivre le README
```

## 📁 Structure

- `terraform/` : Infrastructure AWS
- `ansible/` : Configuration serveurs
- `monitoring/` : Prometheus/Grafana (WSL)
- `docs/` : Documentation + Screenshots
