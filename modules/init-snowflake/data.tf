#data "aws_caller_identity" "current" {}
data "azuread_client_config" "current" {}
data "snowflake_current_account" "current" {}

data "azuread_user" "kirill" {
  user_principal_name = "kirill.podkov_outlook.com#EXT#@kirillpodkovoutlook.onmicrosoft.com"
}