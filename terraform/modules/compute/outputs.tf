output "jenkins_instance_id" {
  description = "ID de l'instance Jenkins"
  value       = aws_instance.jenkins.id
}

output "jenkins_private_ip" {
  description = "IP privee de Jenkins"
  value       = aws_instance.jenkins.private_ip
}

output "jenkins_public_ip" {
  description = "IP publique de Jenkins"
  value       = aws_eip.jenkins.public_ip
}

output "ansible_instance_id" {
  description = "ID de l'instance Ansible"
  value       = aws_instance.ansible.id
}

output "ansible_private_ip" {
  description = "IP privee d'Ansible"
  value       = aws_instance.ansible.private_ip
}

output "ansible_public_ip" {
  description = "IP publique d'Ansible"
  value       = aws_eip.ansible.public_ip
}
