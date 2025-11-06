# Security Group pour ALB Jenkins
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "To Jenkins instances"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = var.instance_security_group_ids
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-sg-alb"
  })
}

# Security Group pour NLB (SSH + Métriques pour toutes les instances)
resource "aws_security_group" "nlb" {
  name        = "${var.project_name}-sg-nlb"
  description = "Security group for Network Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Node Exporter metrics"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "SSH to all instances"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.instance_security_group_ids
  }

  egress {
    description     = "Metrics to all instances"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = var.instance_security_group_ids
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-sg-nlb"
  })
}

# ========================================
# Network Load Balancer pour toutes les instances (SSH + Métriques)
# ========================================
resource "aws_lb" "ansible" {
  name               = "${var.project_name}-nlb-ansible"
  internal           = false
  load_balancer_type = "network"
  subnets            = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nlb-ansible"
    Type = "ansible"
  })
}

# Target Group pour SSH Ansible
resource "aws_lb_target_group" "ansible_ssh" {
  name     = "ansible-ssh-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 22
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg-ansible-ssh"
  })
}

# Target Group pour SSH Jenkins
resource "aws_lb_target_group" "jenkins_ssh" {
  name     = "jenkins-ssh-tg"
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 22
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg-jenkins-ssh"
  })
}

# Target Group pour Métriques Ansible
resource "aws_lb_target_group" "ansible_metrics" {
  name     = "ansible-metrics-tg"
  port     = 9100
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 9100
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg-ansible-metrics"
  })
}

# Target Group pour Métriques Jenkins
resource "aws_lb_target_group" "jenkins_metrics" {
  name     = "jenkins-metrics-tg"
  port     = 9100
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol            = "TCP"
    port                = 9100
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg-jenkins-metrics"
  })
}

# Attachments SSH Ansible
resource "aws_lb_target_group_attachment" "ansible_ssh" {
  target_group_arn = aws_lb_target_group.ansible_ssh.arn
  target_id        = var.ansible_instance_id
  port             = 22
}

# Attachments SSH Jenkins
resource "aws_lb_target_group_attachment" "jenkins_ssh" {
  count = length(var.jenkins_instance_ids)

  target_group_arn = aws_lb_target_group.jenkins_ssh.arn
  target_id        = var.jenkins_instance_ids[count.index]
  port             = 22
}

# Attachments Métriques Ansible
resource "aws_lb_target_group_attachment" "ansible_metrics" {
  target_group_arn = aws_lb_target_group.ansible_metrics.arn
  target_id        = var.ansible_instance_id
  port             = 9100
}

# Attachments Métriques Jenkins
resource "aws_lb_target_group_attachment" "jenkins_metrics" {
  count = length(var.jenkins_instance_ids)

  target_group_arn = aws_lb_target_group.jenkins_metrics.arn
  target_id        = var.jenkins_instance_ids[count.index]
  port             = 9100
}

# Listener SSH Ansible (port 2222 pour différencier)
resource "aws_lb_listener" "ansible_ssh" {
  load_balancer_arn = aws_lb.ansible.arn
  port              = 2222  # Port différent pour Ansible
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ansible_ssh.arn
  }
}

# Listener SSH Jenkins (port 22 pour Jenkins)
resource "aws_lb_listener" "jenkins_ssh" {
  load_balancer_arn = aws_lb.ansible.arn
  port              = 22    # Port standard pour Jenkins
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_ssh.arn
  }
}

# Listener Métriques Ansible (port 9101)
resource "aws_lb_listener" "ansible_metrics" {
  load_balancer_arn = aws_lb.ansible.arn
  port              = 9101  # Port différent pour Ansible metrics
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ansible_metrics.arn
  }
}

# Listener Métriques Jenkins (port 9100)
resource "aws_lb_listener" "jenkins_metrics" {
  load_balancer_arn = aws_lb.ansible.arn
  port              = 9100  # Port standard pour Jenkins metrics
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_metrics.arn
  }
}

# ========================================
# Application Load Balancer pour Jenkins
# ========================================
resource "aws_lb" "jenkins" {
  name               = "${var.project_name}-alb-jenkins"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.subnet_ids

  enable_deletion_protection = false
  enable_http2               = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-alb-jenkins"
    Type = "jenkins"
  })
}

resource "aws_lb_target_group" "jenkins_ui" {
  name     = "jenkins-ui-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/login"
    port                = 8080
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  deregistration_delay = 30

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-tg-jenkins-ui"
  })
}

resource "aws_lb_target_group_attachment" "jenkins_ui" {
  count = length(var.jenkins_instance_ids)

  target_group_arn = aws_lb_target_group.jenkins_ui.arn
  target_id        = var.jenkins_instance_ids[count.index]
  port             = 8080
}

resource "aws_lb_listener" "jenkins_ui" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins_ui.arn
  }
}