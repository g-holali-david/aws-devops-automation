# Infrastructure AWS - Projet DevOps

Ce projet Terraform deploie une infrastructure complete sur AWS pour un pipeline CI/CD avec Jenkins et Ansible.

## Architecture

### Ressources deployees

- **VPC**: 10.0.0.0/16
- **Subnets publics**: 2 subnets dans des AZs differentes
- **Internet Gateway**: Pour l'acces Internet
- **EC2 Instances**:
  - 1 x Jenkins Server (t2.small, Debian)
  - 1 x Ansible Control Server (t2.small, Debian)
- **Security Groups**: Regles de securite pour chaque serveur
- **Elastic IPs**: IPs publiques statiques pour les instances
- **Node Exporter**: Installe sur chaque instance pour le monitoring Prometheus

### Ports ouverts

#### Jenkins Server
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 8080 (Jenkins UI)
- 9100 (Node Exporter)

#### Ansible Server
- 22 (SSH)
- 80 (HTTP)
- 443 (HTTPS)
- 9100 (Node Exporter)

## Prerequisites

- Terraform >= 1.0
- AWS CLI configure avec les credentials
- Cle SSH `devops-key` existante dans AWS (region us-east-1)
- Compte AWS avec les permissions necessaires

## Structure du projet

```
terraform-aws-devops/
├── main.tf                 # Configuration principale
├── variables.tf            # Declaration des variables
├── outputs.tf             # Outputs du deploiement
├── terraform.tfvars       # Valeurs des variables
├── providers.tf           # Configuration du provider AWS
│
├── modules/
│   ├── networking/        # Module VPC et reseau
│   ├── security/          # Module Security Groups
│   └── compute/           # Module EC2 instances
│
└── scripts/
    ├── init.sh            # Script d'initialisation
    └── destroy.sh         # Script de destruction
```

## Utilisation

### 1. Initialisation

```bash
cd terraform-aws-devops
./scripts/init.sh
```

Cette commande va:
- Verifier l'installation de Terraform
- Verifier les credentials AWS
- Verifier l'existence de la cle SSH
- Initialiser Terraform
- Valider la configuration
- Formater le code

### 2. Planification

```bash
terraform plan
```

Permet de visualiser les ressources qui seront creees.

### 3. Deploiement

```bash
terraform apply
```

Tape `yes` pour confirmer le deploiement.

### 4. Recuperation des informations

```bash
terraform output
```

Affiche les IPs publiques, commandes SSH, et URL d'acces.

### 5. Destruction

```bash
./scripts/destroy.sh
```

Ou manuellement:

```bash
terraform destroy
```

## Outputs importants

Apres le deploiement, Terraform affichera:

- **jenkins_public_ip**: IP publique du serveur Jenkins
- **jenkins_url**: URL d'acces a Jenkins (http://IP:8080)
- **jenkins_ssh_command**: Commande pour se connecter en SSH
- **ansible_public_ip**: IP publique du serveur Ansible
- **ansible_ssh_command**: Commande pour se connecter en SSH
- **prometheus_targets**: Targets pour la configuration Prometheus locale

## Connexion SSH

```bash
# Jenkins
ssh -i devops-key.pem admin@<JENKINS_PUBLIC_IP>

# Ansible
ssh -i devops-key.pem admin@<ANSIBLE_PUBLIC_IP>
```

Note: L'utilisateur par defaut pour Debian est `admin`.

## Configuration Prometheus locale

Les instances exposent Node Exporter sur le port 9100. Pour les monitorer avec votre Prometheus local, ajoutez dans `prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'jenkins-server'
    static_configs:
      - targets: ['<JENKINS_PUBLIC_IP>:9100']

  - job_name: 'ansible-server'
    static_configs:
      - targets: ['<ANSIBLE_PUBLIC_IP>:9100']
```

## Personnalisation

### Modifier le type d'instance

Editez `terraform.tfvars`:

```hcl
instance_type = "t2.medium"
```

### Modifier la region

Editez `terraform.tfvars`:

```hcl
aws_region = "eu-west-1"
```

Note: Si vous changez de region, assurez-vous que:
- La cle SSH existe dans la nouvelle region
- L'AMI est disponible dans cette region

### Modifier les CIDRs autorises pour SSH

Editez `terraform.tfvars`:

```hcl
allowed_ssh_cidr = ["YOUR_IP/32"]
```

## Verification de l'infrastructure

### Verifier les instances

```bash
aws ec2 describe-instances \
  --region us-east-1 \
  --filters "Name=tag:Project,Values=devops-tp" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

### Verifier les Security Groups

```bash
aws ec2 describe-security-groups \
  --region us-east-1 \
  --filters "Name=tag:Project,Values=devops-tp" \
  --query 'SecurityGroups[*].[GroupId,GroupName,Description]' \
  --output table
```

### Verifier le VPC

```bash
aws ec2 describe-vpcs \
  --region us-east-1 \
  --filters "Name=tag:Project,Values=devops-tp" \
  --query 'Vpcs[*].[VpcId,CidrBlock,State]' \
  --output table
```

## Troubleshooting

### Erreur: Cle SSH inexistante

```
ERREUR: La cle SSH 'devops-key' n'existe pas dans us-east-1
```

Solution: Creez la cle dans AWS ou modifiez la variable `key_name` dans `terraform.tfvars`.

### Erreur: Credentials AWS

```
ERREUR: Credentials AWS non configures
```

Solution:
```bash
aws configure
```

### Erreur: AMI non disponible

Si l'AMI n'est pas disponible dans votre region, trouvez une AMI Debian equivalente:

```bash
aws ec2 describe-images \
  --owners 136693071363 \
  --filters "Name=name,Values=debian-12-amd64-*" \
  --query 'Images | sort_by(@, &CreationDate) | [-1].[ImageId,Name,CreationDate]' \
  --output table
```

## Prochaines etapes

1. Se connecter aux instances
2. Installer Jenkins sur le serveur Jenkins
3. Installer Ansible sur le serveur Ansible
4. Configurer le pipeline CI/CD
5. Integrer avec GitLab
6. Configurer les webhooks

## Nettoyage

Pour supprimer completement l'infrastructure:

```bash
terraform destroy -auto-approve
```

## Support

Pour toute question ou probleme, verifiez:
- Les logs Terraform: `terraform.log`
- Les logs AWS CloudWatch
- La documentation AWS

## Licence

Projet educatif - TP DevOps
