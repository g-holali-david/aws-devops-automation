# ========================================
# Network Outputs
# ========================================
output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}

output "subnet_ids" {
  description = "IDs des subnets"
  value       = module.network.public_subnet_ids
}

# ========================================
# Compute Outputs
# ========================================
output "ansible_instance_id" {
  description = "ID instance Ansible"
  value       = module.compute.ansible_instance_id
}

output "ansible_public_ip" {
  description = "IP publique Ansible"
  value       = module.compute.ansible_public_ip
}

output "jenkins_instance_ids" {
  description = "IDs instances Jenkins"
  value       = module.compute.jenkins_instance_ids
}

output "jenkins_public_ips" {
  description = "IPs publiques Jenkins"
  value       = module.compute.jenkins_public_ips
}

# ========================================
# Load Balancer Outputs
# ========================================
output "ansible_nlb_dns" {
  description = "DNS du NLB Ansible"
  value       = module.loadbalancer.ansible_nlb_dns
}

output "jenkins_alb_dns" {
  description = "DNS de l'ALB Jenkins"
  value       = module.loadbalancer.jenkins_alb_dns
}

output "jenkins_url" {
  description = "URL Jenkins via ALB"
  value       = "http://${module.loadbalancer.jenkins_alb_dns}:8080"
}

output "ansible_exporter_url" {
  description = "URL Node Exporter Ansible via NLB"
  value       = "http://${module.loadbalancer.ansible_nlb_dns}:9100/metrics"
}

# ========================================
# SSH Commands
# ========================================
output "ssh_commands" {
  description = "Commandes SSH"
  value = {
    ansible = "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.compute.ansible_public_ip}"
    jenkins = [
      for idx, ip in module.compute.jenkins_public_ips :
      "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${ip}"
    ]
  }
}

# ========================================
# Summary
# ========================================
output "deployment_summary" {
  description = "Résumé du déploiement"
  value = <<-EOT
  
  ╔═══════════════════════════════════════════════════════════════╗
  ║              AWS DEVOPS AUTOMATION - DEPLOYED                 ║
  ╚═══════════════════════════════════════════════════════════════╝
  
   Infrastructure:
     Environment:     ${var.environment}
     VPC:             ${module.network.vpc_id}
     Region:          ${var.aws_region}
  
   Ansible Server:
     Instance ID:     ${module.compute.ansible_instance_id}
     Public IP:       ${module.compute.ansible_public_ip}
     NLB DNS:         ${module.loadbalancer.ansible_nlb_dns}
     Node Exporter:   http://${module.loadbalancer.ansible_nlb_dns}:9100
     SSH:             ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${module.compute.ansible_public_ip}
  
   Jenkins Cluster:
     Instance Count:  ${var.jenkins_instance_count}
     IPs:             ${join(", ", module.compute.jenkins_public_ips)}
     ALB DNS:         ${module.loadbalancer.jenkins_alb_dns}
     URL:             http://${module.loadbalancer.jenkins_alb_dns}:8080
  
   Monitoring Targets (Prometheus):
     Ansible:         ${module.loadbalancer.ansible_nlb_dns}:9100
     Jenkins:         ${join(":9100, ", module.compute.jenkins_public_ips)}:9100
     Jenkins App:     ${module.loadbalancer.jenkins_alb_dns}:8080
  
   Next Steps:
     1. Verify Ansible: ansible all -m ping
     2. Deploy with Ansible: ansible-playbook playbooks/site.yml
     3. Access Jenkins: http://${module.loadbalancer.jenkins_alb_dns}:8080
     4. Configure Prometheus with the DNS endpoints above
     5. Setup Grafana dashboards
  
  ╚═══════════════════════════════════════════════════════════════╝
  EOT
}