resource "aws_instance" "jenkins" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [var.jenkins_sg_id]

  root_block_device {
    volume_size           = 40
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl wget git
              
              # Configuration du hostname
              hostnamectl set-hostname jenkins-server
              
              # Configuration de /tmp avec 10GB d'espace
              mount -o remount,size=10G /tmp
              echo "tmpfs /tmp tmpfs defaults,size=10G 0 0" >> /etc/fstab
              
              # Installation de Node Exporter pour Prometheus
              useradd --no-create-home --shell /bin/false node_exporter
              cd /tmp
              wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
              tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
              cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
              chown node_exporter:node_exporter /usr/local/bin/node_exporter
              
              # Creation du service Node Exporter
              cat > /etc/systemd/system/node_exporter.service <<'NODEEOF'
              [Unit]
              Description=Node Exporter
              After=network.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target
              NODEEOF
              
              systemctl daemon-reload
              systemctl start node_exporter
              systemctl enable node_exporter
              EOF

  tags = {
    Name = "${var.project_name}-jenkins-server"
    Role = "Jenkins"
  }
}

resource "aws_instance" "ansible" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = var.subnet_ids[1]
  vpc_security_group_ids = [var.ansible_sg_id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y curl wget git python3 python3-pip
              
              # Configuration du hostname
              hostnamectl set-hostname ansible-control
              
              # Installation de Node Exporter pour Prometheus
              useradd --no-create-home --shell /bin/false node_exporter
              cd /tmp
              wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
              tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
              cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
              chown node_exporter:node_exporter /usr/local/bin/node_exporter
              
              # Creation du service Node Exporter
              cat > /etc/systemd/system/node_exporter.service <<'NODEEOF'
              [Unit]
              Description=Node Exporter
              After=network.target

              [Service]
              User=node_exporter
              Group=node_exporter
              Type=simple
              ExecStart=/usr/local/bin/node_exporter

              [Install]
              WantedBy=multi-user.target
              NODEEOF
              
              systemctl daemon-reload
              systemctl start node_exporter
              systemctl enable node_exporter
              EOF

  tags = {
    Name = "${var.project_name}-ansible-server"
    Role = "Ansible"
  }
}

resource "aws_eip" "jenkins" {
  instance = aws_instance.jenkins.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-jenkins-eip"
  }
}

resource "aws_eip" "ansible" {
  instance = aws_instance.ansible.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-ansible-eip"
  }
}