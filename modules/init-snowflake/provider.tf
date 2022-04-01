provider snowflake {
  username = var.snowflake_user
  password = var.snowflake_password
  account  = var.snowflake_account
  role     = "ACCOUNTADMIN"
}

provider "aws" {
  profile = "default"
  region  = "eu-central-1"
}

#provider "azuread" {
#  client_id     = "00000000-0000-0000-0000-000000000000"
#  client_secret = var.client_secret
#  tenant_id     = "10000000-2000-3000-4000-500000000000"
#}