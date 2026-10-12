resource "aws_cognito_user_pool" "lab" {
  name                     = "va-lab-users"
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = false
  }
}

resource "aws_cognito_user_pool_domain" "lab" {
  domain       = "va-lab-691588646615"
  user_pool_id = aws_cognito_user_pool.lab.id
}

resource "aws_cognito_user_pool_client" "va" {
  name            = "verified-access"
  user_pool_id    = aws_cognito_user_pool.lab.id
  generate_secret = true

  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["openid", "email", "profile"]
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://app.myadvtravel.click/oauth2/idpresponse"]
}