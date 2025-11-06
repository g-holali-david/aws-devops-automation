# Projet Ansible - Configuration Infrastructure DevOps

Ce projet Ansible automatise la configuration complete de l'infrastructure DevOps avec creation d'un utilisateur dedie et installation de Jenkins.

## Architecture

- **Serveur Ansible Control**: Serveur de controle Ansible
- **Serveur Jenkins**: Serveur avec Jenkins installe
- **Utilisateur dedie**: `ansible-admin` (seul utilisateur autorise a se connecter en SSH au serveur Jenkins)

## Structure du projet

```
ansible-devops/
├── ansible.cfg                 # Configuration Ansible
├── inventory/
│   └── hosts.ini              # Inventaire des serveurs
├── playbooks/
│   ├── site.yml               # Playbook principal (tout)
│   ├── setup_users.yml        # Creation utilisateur ansible-admin
│   ├── jenkins.yml            # Installation Jenkins uniquement
│   └── test_connection.yml    # Test de connexion
├── roles/
│   ├── ansible_user/          # Creation utilisateur ansible-admin
│   ├── common/                # Configuration commune
│   ├── jenkins/               # Installation Jenkins
│   └── security/              # Configuration securite SSH
├── group_vars/
│   ├── all.yml                # Variables globales
│   └── jenkins.yml            # Variables Jenkins
└── README.md
```

## Prerequisites

### Sur votre machine locale

1. Ansible installe
2. Acces SSH aux serveurs avec la cle `devops-key.pem`
3. Les serveurs provisionnes via Terraform

### Configuration initiale

1. **Modifier l'inventaire** avec les IPs publiques de vos serveurs:

```bash
nano inventory/hosts.ini
```

Remplacez:
- `JENKINS_PUBLIC_IP` par l'IP publique du serveur Jenkins
- `ANSIBLE_PUBLIC_IP` par l'IP publique du serveur Ansible

2. **Verifier la connexion SSH**:

```bash
ansible all -m ping
```

## Utilisation

### Methode 1: Deploiement complet (recommande)

Execute tous les roles dans l'ordre correct:

```bash
ansible-playbook playbooks/site.yml
```

### Methode 2: Deploiement etape par etape

#### Etape 1: Creer l'utilisateur ansible-admin

```bash
ansible-playbook playbooks/setup_users.yml
```

Cette etape:
- Cree l'utilisateur `ansible-admin` sur tous les serveurs
- Generate une paire de cles SSH sur le serveur ansible-control
- Configure la cle publique sur le serveur Jenkins
- Configure sudo sans mot de passe

#### Etape 2: Configuration commune

```bash
ansible-playbook playbooks/site.yml --tags common
```

Cette etape:
- Met a jour les packages
- Installe les outils communs
- Configure le timezone
- Configure le hostname

#### Etape 3: Configuration de la securite

```bash
ansible-playbook playbooks/site.yml --tags security
```

Cette etape:
- Desactive le login root
- Desactive l'authentification par mot de passe
- Restreint SSH uniquement a l'utilisateur ansible-admin
- Installe et configure fail2ban

#### Etape 4: Installation de Jenkins

```bash
ansible-playbook playbooks/jenkins.yml
```

Cette etape:
- Installe Java 17
- Installe Jenkins
- Configure Jenkins
- Demarre le service Jenkins

### Verification

#### Test de connexion

```bash
ansible-playbook playbooks/test_connection.yml
```

#### Verifier que ansible-admin peut se connecter

Depuis le serveur ansible-control:

```bash
ssh ansible-admin@<JENKINS_IP>
```

#### Recuperer le mot de passe initial Jenkins

```bash
ansible jenkins -m shell -a "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" -u ansible-admin --private-key ~/.ssh/id_rsa
```

## Commandes utiles

### Test de connectivite

```bash
# Avec l'utilisateur admin
ansible all -m ping

# Avec ansible-admin
ansible jenkins -m ping -u ansible-admin --private-key ~/.ssh/id_rsa
```

### Execution avec tags specifiques

```bash
# Uniquement la creation d'utilisateur
ansible-playbook playbooks/site.yml --tags user

# Uniquement la configuration commune
ansible-playbook playbooks/site.yml --tags common

# Uniquement la securite
ansible-playbook playbooks/site.yml --tags security

# Uniquement Jenkins
ansible-playbook playbooks/site.yml --tags jenkins
```

### Execution en mode check (dry-run)

```bash
ansible-playbook playbooks/site.yml --check
```

### Execution avec verbose

```bash
ansible-playbook playbooks/site.yml -v
ansible-playbook playbooks/site.yml -vv
ansible-playbook playbooks/site.yml -vvv
```

### Lister les taches

```bash
ansible-playbook playbooks/site.yml --list-tasks
```

### Lister les tags

```bash
ansible-playbook playbooks/site.yml --list-tags
```

## Variables importantes

### group_vars/all.yml

- `ansible_admin_user`: Nom de l'utilisateur Ansible (par defaut: ansible-admin)
- `timezone`: Timezone du serveur (par defaut: Europe/Paris)
- `common_packages`: Liste des packages a installer

### group_vars/jenkins.yml

- `jenkins_http_port`: Port Jenkins (par defaut: 8080)
- `java_package`: Version de Java (par defaut: openjdk-17-jdk)
- `jenkins_java_options`: Options JVM pour Jenkins

## Roles

### Role: ansible_user

Cree l'utilisateur `ansible-admin` avec:
- Acces sudo sans mot de passe
- Paire de cles SSH generee
- Cle publique deployee sur les serveurs cibles

### Role: common

Configure:
- Mise a jour des packages
- Installation des outils communs
- Configuration timezone et hostname
- Limites systeme

### Role: security

Configure:
- Desactivation du login root
- Desactivation de l'authentification par mot de passe
- Restriction SSH a ansible-admin uniquement
- Installation de fail2ban

### Role: jenkins

Installe et configure:
- Java 17
- Jenkins
- Configuration JVM
- Service Jenkins

## Acces a Jenkins

Apres l'installation:

1. **URL**: `http://<JENKINS_PUBLIC_IP>:8080`

2. **Recuperer le mot de passe initial**:

```bash
# Depuis le serveur ansible-control
ssh ansible-admin@<JENKINS_IP>
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

3. **Configuration initiale**:
   - Coller le mot de passe initial
   - Installer les plugins suggeres
   - Creer le premier utilisateur admin

## Securite

### Restrictions SSH

Apres l'execution du playbook:
- Seul l'utilisateur `ansible-admin` peut se connecter en SSH au serveur Jenkins
- L'utilisateur `admin` ne peut plus se connecter
- L'authentification par mot de passe est desactivee
- Le login root est desactive

### Configuration fail2ban

fail2ban est installe et protege:
- SSH contre les attaques par force brute
- Configuration par defaut avec 5 tentatives max

## Troubleshooting

### Erreur: "Permission denied"

Verifiez que vous utilisez la bonne cle SSH:

```bash
ansible all -m ping --private-key ~/devops-key.pem
```

### Erreur: "User ansible-admin does not exist"

Executez d'abord le playbook de creation d'utilisateur:

```bash
ansible-playbook playbooks/setup_users.yml
```

### Jenkins ne demarre pas

Verifiez les logs:

```bash
ansible jenkins -m shell -a "sudo journalctl -u jenkins -n 50"
```

### Probleme de connexion SSH apres configuration securite

Si vous etes bloque, connectez-vous via la console AWS et:

```bash
sudo nano /etc/ssh/sshd_config
# Commentez la ligne AllowUsers
sudo systemctl restart ssh
```

## Maintenance

### Mettre a jour Jenkins

```bash
ansible jenkins -m apt -a "name=jenkins state=latest" -b
```

### Redemarrer Jenkins

```bash
ansible jenkins -m systemd -a "name=jenkins state=restarted" -b
```

### Sauvegarder Jenkins

```bash
ansible jenkins -m archive -a "path=/var/lib/jenkins dest=/tmp/jenkins-backup.tar.gz" -b
```

## Support

Pour toute question:
1. Consultez les logs Ansible
2. Verifiez la documentation des roles
3. Testez avec `--check` et `-vvv`

## Licence

Projet educatif - TP DevOps
