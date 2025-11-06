#!/bin/bash
# Afficher les outputs

cd "$(dirname "$0")/.."

echo "=== All Outputs ==="
terraform output

echo ""
echo "=== Deployment Summary ==="
terraform output -raw deployment_summary

echo ""
echo "=== DNS Endpoints ==="
echo "Ansible NLB: $(terraform output -raw ansible_nlb_dns)"
echo "Jenkins ALB: $(terraform output -raw jenkins_alb_dns)"
