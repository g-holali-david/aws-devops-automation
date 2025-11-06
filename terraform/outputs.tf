output "vpc_id" {
  description = "ID du VPC cree"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "IDs des subnets publics"
  value       = module.networking.public_subnet_ids
}

output "jenkins_public_ip" {
  description = "IP publique du serveur Jenkins"
  value       = module.compute.jenkins_public_ip
}

output "jenkins_private_ip" {
  description = "IP privee du serveur Jenkins"
  value       = module.compute.jenkins_private_ip
}

output "jenkins_ssh_command" {
  description = "Commande SSH pour se connecter a Jenkins"
  value       = "ssh -i devops-key.pem admin@${module.compute.jenkins_public_ip}"
}

output "jenkins_url" {
  description = "URL d'acces a Jenkins"
  value       = "http://${module.compute.jenkins_public_ip}:8080"
}

output "ansible_public_ip" {
  description = "IP publique du serveur Ansible"
  value       = module.compute.ansible_public_ip
}

output "ansible_private_ip" {
  description = "IP privee du serveur Ansible"
  value       = module.compute.ansible_private_ip
}

output "ansible_ssh_command" {
  description = "Commande SSH pour se connecter a Ansible"
  value       = "ssh -i devops-key.pem admin@${module.compute.ansible_public_ip}"
}

output "prometheus_targets" {
  description = "Targets pour la configuration Prometheus"
  value = {
    jenkins = "${module.compute.jenkins_public_ip}:9100"
    ansible = "${module.compute.ansible_public_ip}:9100"
  }
}
