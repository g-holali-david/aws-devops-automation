# Ansible

## Test connectivité

```bash
ansible all -m ping
```

## Déploiement complet

```bash
# Installe Node Exporter + Jenkins
ansible-playbook playbooks/site.yml
```

## Vérifications

```bash
# Status Node Exporter
ansible all -m systemd -a "name=node_exporter state=started"

# Status Jenkins
ansible jenkins -m systemd -a "name=jenkins state=started"

# Test Node Exporter
ansible all -m uri -a "url=http://localhost:9100/metrics"
```
