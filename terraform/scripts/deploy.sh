#!/bin/bash
# Script de déploiement

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║       AWS DEVOPS AUTOMATION - DEPLOYMENT              ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ $1${NC}"; }

check_prerequisites() {
    print_info "Checking prerequisites..."
    
    command -v terraform >/dev/null 2>&1 || { print_error "Terraform not installed"; exit 1; }
    command -v aws >/dev/null 2>&1 || { print_error "AWS CLI not installed"; exit 1; }
    aws sts get-caller-identity >/dev/null 2>&1 || { print_error "AWS not configured"; exit 1; }
    
    [ ! -f "terraform.tfvars" ] && { print_error "terraform.tfvars not found"; exit 1; }
    
    print_success "Prerequisites OK"
}

terraform_init() {
    print_info "Initializing Terraform..."
    terraform init
    print_success "Initialized"
}

terraform_validate() {
    print_info "Validating configuration..."
    terraform fmt -recursive
    terraform validate
    print_success "Configuration valid"
}

terraform_plan() {
    print_info "Creating plan..."
    terraform plan -out=tfplan
    print_success "Plan created"
}

terraform_apply() {
    print_info "Applying infrastructure..."
    read -p "Continue? (yes/no): " confirm
    [ "$confirm" != "yes" ] && { print_info "Cancelled"; exit 0; }
    
    terraform apply tfplan
    print_success "Infrastructure deployed!"
    
    echo ""
    terraform output deployment_summary
}

print_header
cd "$(dirname "$0")/.."

check_prerequisites
terraform_init
terraform_validate
terraform_plan
terraform_apply
