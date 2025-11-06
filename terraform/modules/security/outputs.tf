output "jenkins_sg_id" {
  description = "ID du security group Jenkins"
  value       = aws_security_group.jenkins.id
}

output "ansible_sg_id" {
  description = "ID du security group Ansible"
  value       = aws_security_group.ansible.id
}
