# Guide de Demarrage Rapide

## Deploiement de l'infrastructure en 5 minutes

### 1. Prerequisites

Avant de commencer, assurez-vous d'avoir:

- [x] Terraform installe (version >= 1.0)
- [x] AWS CLI installe et configure
- [x] La cle SSH `devops-key` existe dans AWS (region us-east-1)
- [x] Acces Internet

### 2. Configuration AWS

```bash
# Configurer AWS CLI si ce n'est pas deja fait
aws configure

# Verifier la connexion
aws sts get-caller-identity

# Verifier la cle SSH
aws ec2 describe-key-pairs --key-names devops-key --region us-east-1
```

### 3. Initialisation du projet

```bash
cd terraform-aws-devops
./scripts/init.sh
```

### 4. Deploiement

```bash
# Visualiser ce qui va etre cree
terraform plan

# Deployer l'infrastructure
terraform apply
```

Tapez `yes` pour confirmer.

### 5. Recuperer les informations

```bash
terraform output
```

Vous obtiendrez:

```
jenkins_public_ip = "X.X.X.X"
jenkins_url = "http://X.X.X.X:8080"
jenkins_ssh_command = "ssh -i devops-key.pem admin@X.X.X.X"
ansible_public_ip = "Y.Y.Y.Y"
ansible_ssh_command = "ssh -i devops-key.pem admin@Y.Y.Y.Y"
```

### 6. Verification

```bash
# Connexion SSH a Jenkins
ssh -i devops-key.pem admin@<JENKINS_PUBLIC_IP>

# Connexion SSH a Ansible
ssh -i devops-key.pem admin@<ANSIBLE_PUBLIC_IP>
```

### 7. Configuration Prometheus locale

Editez votre fichier `prometheus.yml` local et ajoutez:

```yaml
scrape_configs:
  - job_name: 'jenkins-server'
    static_configs:
      - targets: ['<JENKINS_PUBLIC_IP>:9100']
        labels:
          instance: 'jenkins-server'

  - job_name: 'ansible-server'
    static_configs:
      - targets: ['<ANSIBLE_PUBLIC_IP>:9100']
        labels:
          instance: 'ansible-server'
```

Redemarrez Prometheus:

```bash
sudo systemctl restart prometheus
```

Verifiez dans Grafana que les metriques remontent.

## Commandes utiles

### Afficher les outputs
```bash
terraform output
terraform output jenkins_public_ip
```

### Rafraichir l'etat
```bash
terraform refresh
```

### Voir l'etat actuel
```bash
terraform show
```

### Lister les ressources
```bash
terraform state list
```

### Modifier une ressource specifique
```bash
terraform apply -target=module.compute.aws_instance.jenkins
```

### Destruction selective
```bash
terraform destroy -target=module.compute.aws_instance.ansible
```

### Destruction complete
```bash
./scripts/destroy.sh
```

## Prochaines etapes

1. **Installation Jenkins**
   ```bash
   ssh -i devops-key.pem admin@<JENKINS_IP>
   # Suivre le guide d'installation Jenkins
   ```

2. **Installation Ansible**
   ```bash
   ssh -i devops-key.pem admin@<ANSIBLE_IP>
   # Suivre le guide d'installation Ansible
   ```

3. **Configuration du pipeline CI/CD**
   - Creer le Jenkinsfile
   - Configurer les playbooks Ansible
   - Mettre en place les webhooks GitLab

4. **Monitoring**
   - Verifier les metriques dans Prometheus
   - Creer des dashboards Grafana
   - Configurer les alertes

## Troubleshooting rapide

### Probleme de connexion SSH
```bash
# Verifier les Security Groups
aws ec2 describe-security-groups --region us-east-1 --filters "Name=tag:Project,Values=devops-tp"

# Verifier que l'instance est running
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Project,Values=devops-tp"
```

### Jenkins ne repond pas
```bash
ssh -i devops-key.pem admin@<JENKINS_IP>
sudo systemctl status jenkins
sudo journalctl -u jenkins -f
```

### Node Exporter ne remonte pas
```bash
ssh -i devops-key.pem admin@<IP>
sudo systemctl status node_exporter
curl localhost:9100/metrics
```

## Support

En cas de probleme:
1. Consultez les logs Terraform
2. Verifiez la documentation AWS
3. Testez la connectivite reseau
4. Verifiez les Security Groups

## Ressources

- [Documentation Terraform](https://www.terraform.io/docs)
- [Documentation AWS](https://docs.aws.amazon.com/)
- [Documentation Jenkins](https://www.jenkins.io/doc/)
- [Documentation Ansible](https://docs.ansible.com/)
