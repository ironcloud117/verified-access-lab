locals {
  cognito_base = "https://${aws_cognito_user_pool_domain.lab.domain}.auth.eu-west-1.amazoncognito.com"
}

resource "aws_verifiedaccess_trust_provider" "cognito" {
  policy_reference_name    = "cognito"
  trust_provider_type      = "user"
  user_trust_provider_type = "oidc"

  oidc_options {
    issuer                 = "https://${aws_cognito_user_pool.lab.endpoint}"
    authorization_endpoint = "${local.cognito_base}/oauth2/authorize"
    token_endpoint         = "${local.cognito_base}/oauth2/token"
    user_info_endpoint     = "${local.cognito_base}/oauth2/userInfo"
    client_id              = aws_cognito_user_pool_client.va.id
    client_secret          = aws_cognito_user_pool_client.va.client_secret
    scope                  = "openid email profile"
  }
}

resource "aws_verifiedaccess_instance" "lab" {
  description = "va-lab"
}

resource "aws_verifiedaccess_instance_trust_provider_attachment" "lab" {
  verifiedaccess_instance_id       = aws_verifiedaccess_instance.lab.id
  verifiedaccess_trust_provider_id = aws_verifiedaccess_trust_provider.cognito.id
}

resource "aws_verifiedaccess_group" "app" {
  verifiedaccess_instance_id = aws_verifiedaccess_instance.lab.id
  description                = "va-lab-group"

  policy_document = <<-EOT
    permit(principal, action, resource)
    when {
      context has "cognito" &&
      context.cognito has "email" &&
      context.cognito.email == "giovanni.adinolfi@live.it"
    };
  EOT

  depends_on = [aws_verifiedaccess_instance_trust_provider_attachment.lab]
}

resource "aws_security_group" "va_endpoint" {
  name        = "va-lab-endpoint-sg"
  description = "Endpoint Verified Access verso ALB"
  vpc_id      = aws_vpc.lab.id

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.lab.cidr_block]
  }
}

resource "aws_verifiedaccess_endpoint" "app" {
  application_domain       = "app.myadvtravel.click"
  attachment_type          = "vpc"
  domain_certificate_arn   = aws_acm_certificate_validation.app.certificate_arn
  endpoint_domain_prefix   = "app"
  endpoint_type            = "load-balancer"
  security_group_ids       = [aws_security_group.va_endpoint.id]
  verified_access_group_id = aws_verifiedaccess_group.app.id

  load_balancer_options {
    load_balancer_arn = aws_lb.app.arn
    port              = 80
    protocol          = "http"
    subnet_ids        = aws_subnet.private[*].id
  }
}

resource "aws_route53_record" "app" {
  zone_id = data.aws_route53_zone.lab.zone_id
  name    = "app.myadvtravel.click"
  type    = "CNAME"
  ttl     = 60
  records = [aws_verifiedaccess_endpoint.app.endpoint_domain]
}