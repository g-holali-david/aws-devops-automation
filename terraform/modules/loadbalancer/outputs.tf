output "ansible_nlb_id" {
  description = "ID du NLB Ansible"
  value       = aws_lb.ansible.id
}

output "ansible_nlb_arn" {
  description = "ARN du NLB Ansible"
  value       = aws_lb.ansible.arn
}

output "ansible_nlb_dns" {
  description = "DNS du NLB Ansible"
  value       = aws_lb.ansible.dns_name
}

output "jenkins_alb_id" {
  description = "ID de l'ALB Jenkins"
  value       = aws_lb.jenkins.id
}

output "jenkins_alb_arn" {
  description = "ARN de l'ALB Jenkins"
  value       = aws_lb.jenkins.arn
}

output "jenkins_alb_dns" {
  description = "DNS de l'ALB Jenkins"
  value       = aws_lb.jenkins.dns_name
}

# CORRECTION : Remplacez par les nouveaux noms de target groups
output "ansible_target_group_arn" {
  description = "ARN du Target Group Ansible"
  value       = aws_lb_target_group.ansible_ssh.arn  # ← Changé de "ansible" à "ansible_ssh"
}

output "jenkins_target_group_arn" {
  description = "ARN du Target Group Jenkins"
  value       = aws_lb_target_group.jenkins_ui.arn   # ← Changé de "jenkins" à "jenkins_ui"
}

output "alb_sg_id" {
  description = "ID du Security Group ALB"
  value       = aws_security_group.alb.id
}

output "nlb_sg_id" {
  description = "ID du Security Group NLB"
  value       = aws_security_group.nlb.id
}

# Supprimez ces doublons ou gardez une seule version :
output "nlb_dns_name" {
  description = "DNS name du NLB Ansible"
  value       = aws_lb.ansible.dns_name
}

output "alb_dns_name" {
  description = "DNS name de l'ALB Jenkins"
  value       = aws_lb.jenkins.dns_name
}