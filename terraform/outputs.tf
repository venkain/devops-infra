output "app_url" {
  value = "Please wait 2-5 minutes after initial deployment and open https://${var.domain == "" ? aws_alb.app.dns_name : join(".", list(var.app_name, var.domain))}"
}

output "bastion_ip" {
  value = "Bastion IP: ${aws_eip.bastion.public_ip}, user: ubuntu, keys: ${var.ssh_public_key_names}."
}
