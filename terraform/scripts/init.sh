#!/bin/bash

set -e

echo "=========================================="
echo "Initialisation de l'infrastructure AWS"
echo "=========================================="

echo ""
echo "Etape 1: Verification de Terraform..."
if ! command -v terraform &> /dev/null; then
    echo "ERREUR: Terraform n'est pas installe"
    exit 1
fi

TERRAFORM_VERSION=$(terraform version | head -n 1)
echo "Terraform trouve: $TERRAFORM_VERSION"

echo ""
echo "Etape 2: Verification des credentials AWS..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERREUR: Credentials AWS non configures"
    echo "Executez: aws configure"
    exit 1
fi

echo "Credentials AWS OK"
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
echo "Compte AWS: $AWS_ACCOUNT"

echo ""
echo "Etape 3: Verification de la cle SSH devops-key..."
if ! aws ec2 describe-key-pairs --key-names devops-key --region us-east-1 &> /dev/null; then
    echo "ATTENTION: La cle SSH 'devops-key' n'existe pas dans us-east-1"
    echo "Veuillez la creer avant de continuer"
    exit 1
fi

echo "Cle SSH 'devops-key' trouvee"

echo ""
echo "Etape 4: Initialisation de Terraform..."
terraform init

echo ""
echo "Etape 5: Validation de la configuration..."
terraform validate

echo ""
echo "Etape 6: Formatage du code..."
terraform fmt -recursive

echo ""
echo "=========================================="
echo "Initialisation terminee avec succes!"
echo "=========================================="
echo ""
echo "Prochaines etapes:"
echo "1. Verifier le plan: terraform plan"
echo "2. Appliquer les changements: terraform apply"
echo ""
