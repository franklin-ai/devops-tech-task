# self-signed certificate with a fake domain
data "aws_partition" "current" {}

# acmpca certificate authority
resource "aws_acmpca_certificate_authority" "fake" {
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
  certificate_authority_arn = aws_acmpca_certificate_authority.fake.arn
  actions                   = ["IssueCertificate", "GetCertificate", "ListPermissions"]
  principal                 = "acm.amazonaws.com"
}

resource "aws_acmpca_certificate_authority_certificate" "fake" {
  certificate_authority_arn = aws_acmpca_certificate_authority.fake.arn

  certificate       = aws_acmpca_certificate.ca.certificate
  certificate_chain = aws_acmpca_certificate.ca.certificate_chain
}

resource "aws_acmpca_certificate" "ca" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.fake.arn
  certificate_signing_request = aws_acmpca_certificate_authority.fake.certificate_signing_request
  signing_algorithm           = "SHA512WITHRSA"

  template_arn = "arn:${data.aws_partition.current.partition}:acm-pca:::template/RootCACertificate/V1"

  validity {
    type  = "YEARS"
    value = 10
  }
}

# our fake certificate
resource "tls_private_key" "fake" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "fake" {
  private_key_pem = tls_private_key.fake.private_key_pem
  dns_names       = ["*.amazonaws.com"]

  subject {
    common_name = "amazonaws.com"
  }
}

resource "aws_acmpca_certificate" "fake" {
  certificate_authority_arn   = aws_acmpca_certificate_authority.fake.arn
  certificate_signing_request = trimspace(tls_cert_request.fake.cert_request_pem)
  signing_algorithm           = "SHA512WITHRSA"

  validity {
    type  = "DAYS"
    value = 30
  }
}

resource "aws_acm_certificate" "fake" {
  private_key       = tls_private_key.fake.private_key_pem
  certificate_body  = aws_acmpca_certificate.fake.certificate
  certificate_chain = aws_acmpca_certificate.ca.certificate

  tags = {
    role = "ecs"
    name = "devops-tech-task"
  }
}
