resource "azuread_application" "oauth" {
  display_name    = "Snowflake"
  identifier_uris = ["https://snowflake-oauth.kirillpodkovoutlook.onmicrosoft.com"]
  owners          = [data.azuread_client_config.current.object_id, data.azuread_user.kirill.object_id]

  api {
    mapped_claims_enabled = true

    # This permissions allows to delegate an application on behalf of an user to connect to snowflake to any role. This is used for example for sagemaker notebooks.
    oauth2_permission_scope {
      admin_consent_description  = "Allows an app to login on behalf of user with his permission"
      admin_consent_display_name = "Snowflake User Role Access"
      enabled                    = true
      id                         = uuidv5("oid", "user_impersonation")
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Snowflake User Role Access"
      value                      = "user_impersonation"
    }

    oauth2_permission_scope {
      admin_consent_description  = "Assume Any Role in Snowflake"
      admin_consent_display_name = "Assume Role"
      enabled                    = true
      id                         = uuidv5("oid", "SESSION:ROLE-ANY")
      type                       = "Admin"
      value                      = "SESSION:ROLE-ANY"
    }
  }

  dynamic "app_role" {
    for_each = ["db_1", "db_2", "db_3"]
    content {
      allowed_member_types = ["Application"]
      description          = "Admins can manage roles and perform all task actions"
      display_name         = "${lower(app_role.key)}_admin"
      enabled              = true
      id                   = uuidv5("oid", app_role.key)
      value                = "session:role:${lower(app_role.key)}_admin"
    }
  }

  feature_tags {
    gallery = false
  }
  lifecycle {
    ignore_changes = [identifier_uris, web]
  }
}

resource "azuread_service_principal" "oauth" {
  owners          = [data.azuread_client_config.current.object_id, data.azuread_user.kirill.object_id]
  application_id = azuread_application.oauth.application_id
  depends_on     = [azuread_application.oauth]
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
  ], tolist(azuread_application.oauth.identifier_uris))
  token_user_mapping_claims = [
    "upn"
  ]
  lifecycle {
    ignore_changes = [audience_urls]
  }
}
