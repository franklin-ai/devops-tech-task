# resources needed to enble ssl cert creation for the hello-world app are disabled by default
# and require the user to enable via the enable_ssl input variable
# this is because aws charges $400+ to run their certificate authority

# self-signed certificate authority
data "aws_partition" "current" {}

# acmpca certificate authority
resource "aws_acmpca_certificate_authority" "fake" {
  count = var.enable_ssl ? 1 : 0

  permanent_deletion_time_in_days = 7
  type                            = "ROOT"

  certificate_authority_configuration {
    key_algorithm     = "RSA_4096"
    signing_algorithm = "SHA512WITHRSA"

    subject {
      common_name = "amazonaws.com"
    }
  }

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}

resource "aws_acmpca_permission" "fake" {
  count = var.enable_ssl ? 1 : 0

  certificate_authority_arn = aws_acmpca_certificate_authority.fake[0].arn
  actions                   = ["IssueCertificate", "GetCertificate", "ListPermissions"]
  principal                 = "acm.amazonaws.com"
}

resource "aws_acmpca_certificate_authority_certificate" "fake" {
  count = var.enable_ssl ? 1 : 0

  certificate_authority_arn = aws_acmpca_certificate_authority.fake[0].arn
  certificate               = aws_acmpca_certificate.ca[0].certificate
  certificate_chain         = aws_acmpca_certificate.ca[0].certificate_chain
}

resource "aws_acmpca_certificate" "ca" {
  count = var.enable_ssl ? 1 : 0

  certificate_authority_arn   = aws_acmpca_certificate_authority.fake[0].arn
  certificate_signing_request = aws_acmpca_certificate_authority.fake[0].certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"
  template_arn                = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 10
  }
}

# our fake certificate
resource "tls_private_key" "fake" {
  count = var.enable_ssl ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "fake" {
  count = var.enable_ssl ? 1 : 0

  private_key_pem = tls_private_key.fake[0].private_key_pem
  dns_names       = ["*.amazonaws.com"]

  subject {
    common_name = "amazonaws.com"
  }
}

resource "aws_acmpca_certificate" "fake" {
  count = var.enable_ssl ? 1 : 0

  certificate_authority_arn   = aws_acmpca_certificate_authority.fake[0].arn
  certificate_signing_request = trimspace(tls_cert_request.fake[0].cert_request_pem)
  signing_algorithm           = "SHA512WITHRSA"

  validity {
    type  = "DAYS"
    value = 30
  }
}

resource "aws_acm_certificate" "fake" {
  count = var.enable_ssl ? 1 : 0

  private_key       = tls_private_key.fake[0].private_key_pem
  certificate_body  = aws_acmpca_certificate.fake[0].certificate
  certificate_chain = aws_acmpca_certificate.ca[0].certificate

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}
