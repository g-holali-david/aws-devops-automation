output "ansible_instance_id" {
  description = "ID de l'instance Ansible"
  value       = aws_instance.ansible.id
}

output "ansible_public_ip" {
  description = "IP publique Ansible"
  value       = aws_instance.ansible.public_ip
}

output "ansible_private_ip" {
  description = "IP privée Ansible"
  value       = aws_instance.ansible.private_ip
}

output "jenkins_instance_ids" {
  description = "IDs des instances Jenkins"
  value       = aws_instance.jenkins[*].id
}

output "jenkins_public_ips" {
  description = "IPs publiques Jenkins"
  value       = aws_instance.jenkins[*].public_ip
}

output "jenkins_private_ips" {
  description = "IPs privées Jenkins"
  value       = aws_instance.jenkins[*].private_ip
}

output "jenkins_instances" {
  description = "Informations complètes Jenkins"
  value = [
    for idx, instance in aws_instance.jenkins : {
      name       = "jenkins-srv${idx + 1}"
      id         = instance.id
      public_ip  = instance.public_ip
      private_ip = instance.private_ip
    }
  ]
}

output "ansible_sg_id" {
  description = "ID du Security Group Ansible"
  value       = aws_security_group.ansible.id
}

output "jenkins_sg_id" {
  description = "ID du Security Group Jenkins"
  value       = aws_security_group.jenkins.id
}

output "private_key_path" {
  description = "Chemin vers la clé privée"
  value       = local_file.private_key.filename
  sensitive   = true
}