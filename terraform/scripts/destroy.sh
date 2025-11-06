#!/bin/bash

set -e

echo "=========================================="
echo "Destruction de l'infrastructure AWS"
echo "=========================================="

echo ""
echo "ATTENTION: Cette action va detruire toutes les ressources!"
echo ""
read -p "Etes-vous sur de vouloir continuer? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Operation annulee"
    exit 0
fi

echo ""
echo "Verification des ressources a detruire..."
terraform plan -destroy

echo ""
read -p "Confirmer la destruction? (yes/no): " FINAL_CONFIRM

if [ "$FINAL_CONFIRM" != "yes" ]; then
    echo "Operation annulee"
    exit 0
fi

echo ""
echo "Destruction en cours..."
terraform destroy -auto-approve

echo ""
echo "=========================================="
echo "Infrastructure detruite avec succes!"
echo "=========================================="
