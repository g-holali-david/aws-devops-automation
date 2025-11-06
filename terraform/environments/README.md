# Environments

Configuration spécifique par environnement.

## Usage

### Dev
```bash
terraform apply -var-file=environments/dev/dev.tfvars
```

### Prod
```bash
terraform apply -var-file=environments/prod/prod.tfvars
```

## Différences

| Config | Dev | Prod |
|--------|-----|------|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| AZs | 2 | 3 |
| Ansible | t2.small | t3.medium |
| Jenkins | t2.medium | t3.large |
| Jenkins Count | 2 | 3 |
