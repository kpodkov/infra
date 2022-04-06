resource "azuread_application" "snowflake" {
  display_name    = "Snowflake"
  identifier_uris = [
    "https://snowflake-oauth.kirillpodkovoutlook.onmicrosoft.com",
    lower(data.snowflake_current_account.current.url)
  ]
  owners = [data.azuread_client_config.current.object_id]
  lifecycle {
    ignore_changes = [web]
  }
}

resource "azuread_service_principal" "snowflake" {
  application_id                = azuread_application.snowflake.application_id
  app_role_assignment_required  = false
  owners                        = [data.azuread_client_config.current.object_id]
  preferred_single_sign_on_mode = "saml"
  feature_tags {
    gallery               = true
    custom_single_sign_on = true
  }
  depends_on = [
    azuread_application.snowflake
  ]
  lifecycle {
    ignore_changes = [login_url]
  }
}

resource "snowflake_external_oauth_integration" "azure" {
  name                             = "AZURE_OAUTH"
  type                             = "AZURE"
  enabled                          = true
  issuer                           = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}"
  snowflake_user_mapping_attribute = "LOGIN_NAME"
  jws_keys_urls                    = ["https://login.windows.net/common/discovery/keys"]
  audience_urls                    = concat([
    "https://analysis.windows.net/powerbi/connector/Snowflake"
  ], tolist(azuread_application.snowflake.identifier_uris))
  token_user_mapping_claims = [
    "upn"
  ]
  lifecycle {
    ignore_changes = [audience_urls]
  }
}
