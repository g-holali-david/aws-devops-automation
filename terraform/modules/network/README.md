# Module Network

Module pour créer le réseau AWS (VPC, Subnets, IGW).

## Ressources créées

- 1 VPC
- N Subnets publics (selon AZs)
- 1 Internet Gateway
- 1 Route Table publique

## Usage

```hcl
module "network" {
  source = "./modules/network"

  project_name       = "my-project"
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["eu-west-1a", "eu-west-1b"]
}
```
