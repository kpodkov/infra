resource "azuread_application" "sso" {
  display_name = "Snowflake"
  owners       = [data.azuread_client_config.current.object_id]
  provisioner "local-exec" {
    command = "sleep 20"
  }
  provisioner "local-exec" {
    command = "az rest --method PATCH --uri 'https://graph.microsoft.com/v1.0/applications/${self.object_id}' --body '{\"optionalClaims\": {\"saml2Token\": [{\"name\": \"groups\", \"additionalProperties\": [\"sam_account_name\"]}]}}'"
  }
}

resource "azuread_service_principal" "sso" {
  application_id               = azuread_application.sso.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
  feature_tags {
    gallery = true
  }
}


resource "snowflake_saml_integration" "saml_integration" {
  name            = "saml_integration"
  saml2_provider  = "AzureAD"
  saml2_issuer    = "https://sts.windows.net/62fa15fd-0fb1-432a-96fd-ef6e5d53587c/"
  saml2_sso_url   = "https://login.microsoftonline.com/62fa15fd-0fb1-432a-96fd-ef6e5d53587c/saml2"
  saml2_x509_cert = ""
  enabled         = true
}