#!/bin/bash
# Script de destruction

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${RED}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║              DESTROY INFRASTRUCTURE                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}WARNING: This will destroy ALL resources!${NC}"
read -p "Type 'destroy' to confirm: " confirm

if [ "$confirm" != "destroy" ]; then
    echo "Cancelled"
    exit 0
fi

cd "$(dirname "$0")/.."
terraform destroy

echo -e "${RED}Infrastructure destroyed${NC}"
