resource "null_resource" "url" {
  triggers = {
    address = "https://${var.domain == "" ? aws_alb.app.dns_name : join(".", list(var.app_name, var.domain))}"
  }
}

// join(".", list(var.app_name, var.domain))
output "app_url" {
  value = "Please wait 5-10 minutes after initial deployment and open ${null_resource.url.triggers.address}"
}

output "bastion_ip" {
  value = "Bastion IP: ${aws_eip.bastion.public_ip}, user: ubuntu, keys: ${var.ssh_public_key_names}."
}
