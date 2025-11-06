# Monitoring - Prometheus & Grafana sur WSL

## Installation Prometheus (WSL)

```bash
# Télécharger
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v2.47.0/prometheus-2.47.0.linux-amd64.tar.gz
tar xzf prometheus-2.47.0.linux-amd64.tar.gz
cd prometheus-2.47.0.linux-amd64

# Installer
sudo cp prometheus promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp -r consoles console_libraries /etc/prometheus/

# Créer utilisateur
sudo useradd --no-create-home --shell /bin/false prometheus
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus
```

## Configuration

```bash
# Copier la config générée par Terraform
sudo cp ~/aws-devops-automation/monitoring/prometheus.yml /etc/prometheus/
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml

# Créer service systemd
sudo tee /etc/systemd/system/prometheus.service << 'PROMSERVICE'
[Unit]
Description=Prometheus
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file=/etc/prometheus/prometheus.yml \
    --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target
PROMSERVICE

# Démarrer
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
sudo systemctl status prometheus
```

## Accès Prometheus

http://localhost:9090

Vérifier les targets: http://localhost:9090/targets

## Installation Grafana (WSL)

```bash
# Ajouter le repository
sudo apt-get install -y apt-transport-https software-properties-common
wget -q -O /usr/share/keyrings/grafana.key https://apt.grafana.com/gpg.key
echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Installer
sudo apt-get update
sudo apt-get install grafana

# Démarrer
sudo systemctl start grafana-server
sudo systemctl enable grafana-server
sudo systemctl status grafana-server
```

## Accès Grafana

http://localhost:3000

Login: admin / admin (changez au premier login)

## Configuration Grafana

1. Add Data Source
2. Choisir Prometheus
3. URL: http://localhost:9090
4. Save & Test

## Dashboards recommandés

- Node Exporter Full (ID: 1860)
- Jenkins Performance (ID: 9964)

Import via Dashboard ID dans Grafana.
