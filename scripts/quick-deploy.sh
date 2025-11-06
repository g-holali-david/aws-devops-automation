#!/bin/bash
set -e

echo "🚀 Déploiement rapide..."

cd terraform/
terraform init
terraform apply -auto-approve

echo "✓ Infrastructure déployée!"
terraform output summary

cd ../ansible
echo "⏳ Attente 60s pour l'initialisation..."
sleep 60

echo "🔧 Configuration des serveurs..."
ansible-playbook playbooks/site.yml

echo "✓ Terminé!"
