# Module Load Balancer

Module pour créer les Load Balancers (NLB et ALB).

## Ressources créées

- 1 Network Load Balancer (Ansible)
- 1 Application Load Balancer (Jenkins)
- 2 Target Groups
- 2 Listeners
- 1 Security Group (ALB)

## Usage

```hcl
module "loadbalancer" {
  source = "./modules/loadbalancer"

  project_name         = "my-project"
  vpc_id               = module.network.vpc_id
  subnet_ids           = module.network.public_subnet_ids
  ansible_instance_id  = module.compute.ansible_instance_id
  jenkins_instance_ids = module.compute.jenkins_instance_ids
}
```

## Load Balancers

### NLB Ansible
- Type: Network Load Balancer
- Port: 9100 (Node Exporter)
- Protocol: TCP
- Health Check: TCP sur port 9100

### ALB Jenkins
- Type: Application Load Balancer
- Port: 8080 (Jenkins UI)
- Protocol: HTTP
- Health Check: HTTP GET /login
