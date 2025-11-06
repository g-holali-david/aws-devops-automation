# Création de la key pair
resource "tls_private_key" "devops_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "devops_key" {
  key_name   = "devops-key"
  public_key = tls_private_key.devops_key.public_key_openssh
}

# Sauvegarde de la clé privée
resource "local_file" "private_key" {
  content  = tls_private_key.devops_key.private_key_pem
  filename = "${path.module}/devops-key.pem"
  file_permission = "0400"
}

# Security Group Ansible
resource "aws_security_group" "ansible" {
  name        = "${var.project_name}-sg-ansible"
  description = "Security group for Ansible server"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-sg-ansible"
  })
}

# Security Group Jenkins
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-sg-jenkins"
  description = "Security group for Jenkins servers"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-sg-jenkins"
  })
}

# Ansible Instance
resource "aws_instance" "ansible" {
  ami                    = var.ami_id
  instance_type          = var.ansible_instance_type
  key_name               = aws_key_pair.devops_key.key_name
  subnet_id              = var.subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ansible.id]

  user_data = <<-EOF
    #!/bin/bash
    set -e
    apt-get update -y
    apt-get upgrade -y
    apt-get install -y software-properties-common
    add-apt-repository --yes --update ppa:ansible/ansible
    apt-get install -y ansible curl wget git vim htop
    
    cat > /home/ubuntu/install-status.txt << 'STATUS'
    Installation completed: $(date)
    Ansible: $(ansible --version | head -n 1)
    STATUS
    chown ubuntu:ubuntu /home/ubuntu/install-status.txt
  EOF

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.common_tags, {
    Name = "ansible-srv"
    Role = "ansible-controller"
  })
}

# Jenkins Instances
resource "aws_instance" "jenkins" {
  count = var.jenkins_instance_count

  ami                    = var.ami_id
  instance_type          = var.jenkins_instance_type
  key_name               = aws_key_pair.devops_key.key_name
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [aws_security_group.jenkins.id]

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = merge(var.common_tags, {
    Name  = "jenkins-srv${count.index + 1}"
    Role  = "jenkins"
    Index = count.index + 1
  })
}