resource "tls_private_key" "ca" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "ca" {
  key_algorithm = "${tls_private_key.ca.algorithm}"
  private_key_pem = "${tls_private_key.ca.private_key_pem}"

  subject {
    common_name = "Test CA"
    organization = "${var.organization}"
    country = "${var.country}"
  }

  validity_period_hours = 43800
  is_ca_certificate = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
    "cert_signing"
  ]
}

resource "tls_private_key" "cert" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

# Register with own domain or use Amazon's domain
resource "null_resource" "domain" {
    triggers = {
        domain = "${var.domain == "" ? "*.amazonaws.com" : var.domain}"
    }
}
resource "tls_cert_request" "cert" {
  key_algorithm = "${tls_private_key.cert.algorithm}"
  private_key_pem = "${tls_private_key.cert.private_key_pem}"

  subject {
    common_name = "${null_resource.domain.triggers.domain}"
    organization = "${var.organization}"
    country = "${var.country}"
  }

  dns_names = ["${null_resource.domain.triggers.domain}"]
}

resource "tls_locally_signed_cert" "cert" {
  cert_request_pem = "${tls_cert_request.cert.cert_request_pem}"

  ca_key_algorithm = "${tls_private_key.ca.algorithm}"
  ca_private_key_pem = "${tls_private_key.ca.private_key_pem}"
  ca_cert_pem = "${tls_self_signed_cert.ca.cert_pem}"

  validity_period_hours = 43800

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "aws_iam_server_certificate" "devops-cert" {
  name             = "${var.app_name}-${var.environment}"
  certificate_body = "${tls_locally_signed_cert.cert.cert_pem}"
  private_key      = "${tls_private_key.cert.private_key_pem}"
}
